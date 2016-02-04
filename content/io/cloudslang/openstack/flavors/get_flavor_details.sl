#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Shows details for a specified flavor ID.
#
# Inputs:
#   - host - OpenStack machine host
#   - identity_port - optional - port used for OpenStack authentication - Default: '5000'
#   - compute_port - optional - port used for OpenStack computations - Default: '8774'
#   - tenant_name - name of OpenStack project that contains specified flavor with details to be retrieved
#   - flavor_id - ID of flavor with details to be retrieved
#   - username - optional - username used for URL authentication; for NTLM authentication
#                           - Format: 'domain\user'
#   - password - optional - password used for URL authentication
#   - proxy_host - optional - proxy server used to access OpenStack services
#   - proxy_port - optional - proxy server port used to access OpenStack services - Default: '8080'
#   - proxy_username - optional - user name used when connecting to proxy
#   - proxy_password - optional - proxy server password associated with <proxy_username> input value
# Outputs:
#   - return_result - response of operation in case of success, error message otherwise
#   - error_message - return_result if status_code is not '200'
#   - return_code - '0' if success, '-1' otherwise
#   - status_code - code returned by operation
# Results:
#   - SUCCESS - details of specified flavor were successfully retrieved
#   - GET_AUTHENTICATION_TOKEN_FAILURE - authentication token cannot be obtained from authentication call response
#   - GET_TENANT_ID_FAILURE - tenant_id corresponding to tenant_name cannot be obtained
#                             from authentication call response
#   - GET_AUTHENTICATION_FAILURE - authentication call fails
#   - GET_FLAVOR_DETAILS_FAILURE - details of specified flavor could not be retrieved
####################################################

namespace: io.cloudslang.openstack.flavors

imports:
  openstack: io.cloudslang.openstack
  rest: io.cloudslang.base.network.rest

flow:
  name: get_flavor_details
  inputs:
    - host
    - identity_port: '5000'
    - compute_port: '8774'
    - tenant_name
    - flavor_id
    - username:
        required: false
    - password:
        required: false
    - proxy_host:
        required: false
    - proxy_port:
        default: '8080'
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false

  workflow:
    - authentication:
        do:
          openstack.get_authentication_flow:
            - host
            - identity_port
            - tenant_name
            - username
            - password
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
        publish:
          - token
          - tenant_id
          - return_result
          - error_message
        navigate:
          SUCCESS: get_flavor_details
          GET_AUTHENTICATION_TOKEN_FAILURE: GET_AUTHENTICATION_TOKEN_FAILURE
          GET_TENANT_ID_FAILURE: GET_TENANT_ID_FAILURE
          GET_AUTHENTICATION_FAILURE: GET_AUTHENTICATION_FAILURE

    - get_flavor_details:
        do:
          rest.http_client_get:
            - url: ${'http://'+ host + ':' + compute_port + '/v2/' + tenant_id + '/flavors/' + flavor_id}
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - headers: ${'X-AUTH-TOKEN:' + token}
            - content_type: 'application/json'
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
        navigate:
          SUCCESS: SUCCESS
          FAILURE: GET_FLAVOR_DETAILS_FAILURE

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code

  results:
    - SUCCESS
    - GET_AUTHENTICATION_TOKEN_FAILURE
    - GET_TENANT_ID_FAILURE
    - GET_AUTHENTICATION_FAILURE
    - GET_FLAVOR_DETAILS_FAILURE