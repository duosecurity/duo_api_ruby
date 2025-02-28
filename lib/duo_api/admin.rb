# frozen_string_literal: true

require_relative 'api_client'
require_relative 'api_helpers'

class DuoApi
  ##
  # Duo Admin API (https://duo.com/docs/adminapi)
  #
  class Admin < DuoApi
    ##
    # Users
    #
    def get_users(**optional_params)
      # optional_params: username, email, user_id_list, username_list
      optional_params.tap do |p|
        p[:user_id_list] = json_serialized_array(p[:user_id_list]) if p[:user_id_list]
        p[:username_list] = json_serialized_array(p[:username_list]) if p[:username_list]
      end
      get_all('/admin/v1/users', optional_params)[:response]
    end

    def create_user(username:, **optional_params)
      # optional_params: alias1, alias2, alias3, alias4, aliases, realname, email,
      #                  enable_auto_prompt, status, notes, firstname, lastname
      optional_params.tap do |p|
        p[:aliases] = serialized_aliases(p[:aliases]) if p[:aliases]
      end
      params = optional_params.merge({ username: username })
      post('/admin/v1/users', params)[:response]
    end

    def bulk_create_users(users:)
      # Each user hash in users array requires :username and supports the following
      # optional keys: realname, emaiml, status, notes, firstname, lastname
      params = { users: json_serialized_array(users) }
      post('/admin/v1/users/bulk_create', params)[:response]
    end

    def bulk_restore_users(user_id_list:)
      params = { user_id_list: json_serialized_array(user_id_list) }
      post('/admin/v1/users/bulk_restore', params)[:response]
    end

    def bulk_trash_users(user_id_list:)
      params = { user_id_list: json_serialized_array(user_id_list) }
      post('/admin/v1/users/bulk_send_to_trash', params)[:response]
    end

    def get_user(user_id:)
      get("/admin/v1/users/#{user_id}")[:response]
    end

    def update_user(user_id:, **optional_params)
      # optional_params: alias1, alias2, alias3, alias4, aliases, realname, email,
      #                  enable_auto_prompt, status, notes, firstname, lastname,
      #                  username
      optional_params.tap do |p|
        p[:aliases] = serialized_aliases(p[:aliases]) if p[:aliases]
      end
      post("/admin/v1/users/#{user_id}", optional_params)[:response]
    end

    def delete_user(user_id:)
      delete("/admin/v1/users/#{user_id}")[:response]
    end

    def enroll_user(username:, email:, **optional_params)
      # optional_params: valid_secs
      params = optional_params.merge({ username: username, email: email })
      post('/admin/v1/users/enroll', params)[:response]
    end

    def create_user_bypass_codes(user_id:, **optional_params)
      # optional_params: count, codes, preserve_existing, reuse_count, valid_secs
      optional_params.tap do |p|
        p[:codes] = csv_serialized_array(p[:codes]) if p[:codes]
      end
      post("/admin/v1/users/#{user_id}/bypass_codes", optional_params)[:response]
    end

    def get_user_bypass_codes(user_id:)
      get_all("/admin/v1/users/#{user_id}/bypass_codes")[:response]
    end

    def get_user_groups(user_id:)
      get_all("/admin/v1/users/#{user_id}/groups")[:response]
    end

    def add_user_group(user_id:, group_id:)
      params = { group_id: group_id }
      post("/admin/v1/users/#{user_id}/groups", params)[:response]
    end

    def remove_user_group(user_id:, group_id:)
      delete("/admin/v1/users/#{user_id}/groups/#{group_id}")[:response]
    end

    def get_user_phones(user_id:)
      get_all("/admin/v1/users/#{user_id}/phones")[:response]
    end

    def add_user_phone(user_id:, phone_id:)
      params = { phone_id: phone_id }
      post("/admin/v1/users/#{user_id}/phones", params)[:response]
    end

    def remove_user_phone(user_id:, phone_id:)
      delete("/admin/v1/users/#{user_id}/phones/#{phone_id}")[:response]
    end

    def get_user_hardware_tokens(user_id:)
      get_all("/admin/v1/users/#{user_id}/tokens")[:response]
    end

    def add_user_hardware_token(user_id:, token_id:)
      params = { token_id: token_id }
      post("/admin/v1/users/#{user_id}/tokens", params)[:response]
    end

    def remove_user_hardware_token(user_id:, token_id:)
      delete("/admin/v1/users/#{user_id}/tokens/#{token_id}")[:response]
    end

    def get_user_webauthn_credentials(user_id:)
      get_all("/admin/v1/users/#{user_id}/webauthncredentials")[:response]
    end

    def get_user_desktop_authenticators(user_id:)
      get_all("/admin/v1/users/#{user_id}/desktopauthenticators")[:response]
    end

    def sync_user(username:, directory_key:)
      params = { username: username }
      post("/admin/v1/users/directorysync/#{directory_key}/syncuser", params)[:response]
    end

    def send_verification_push(user_id:, phone_id:)
      params = { phone_id: phone_id }
      post("/admin/v1/users/#{user_id}/send_verification_push", params)[:response]
    end

    def get_verification_push_response(user_id:, push_id:)
      params = { push_id: push_id }
      get("/admin/v1/users/#{user_id}/verification_push_response", params)[:response]
    end

    ##
    # Bulk Operations
    #
    def bulk_operations(operations:)
      # Each hash in user_operations array requires :method, :path, and :body
      # Each :body has the same parameter requirements as the individual operation
      # Supported operations:
      #   Create User:       POST /admin/v1/users
      #   Modify User:       POST /admin/v1/users/[user_id]
      #   Delete User:     DELETE /admin/v1/users/[user_id]
      #   Add User Group:    POST /admin/v1/users/[user_id]/groups
      #   Remove User Group: POST /admin/v1/users/[user_id]/groups/[group_id]
      operations.each{ |o| o[:body][:aliases] = serialized_aliases(o[:body][:aliases]) if o[:body][:aliases] }
      params = { operations: json_serialized_array(operations) }
      post('/admin/v1/bulk', params)[:response]
    end

    ##
    # Groups
    #
    def get_groups(**optional_params)
      # optional_params: group_id_list
      get_all('/admin/v1/groups', optional_params)[:response]
    end

    def create_group(name:, **optional_params)
      # optional_params: desc, status
      params = optional_params.merge({ name: name })
      post('/admin/v1/groups', params)[:response]
    end

    def get_group(group_id:)
      get("/admin/v2/groups/#{group_id}")[:response]
    end

    def get_group_users(group_id:)
      get_all("/admin/v2/groups/#{group_id}/users")[:response]
    end

    def update_group(group_id:, **optional_params)
      # optional_params: desc, status, name
      post("/admin/v1/groups/#{group_id}", optional_params)[:response]
    end

    def delete_group(group_id:)
      delete("/admin/v1/groups/#{group_id}")[:response]
    end

    ##
    # Phones
    #
    def get_phones(**optional_params)
      # optional_params: number, extension
      get_all('/admin/v1/phones', optional_params)[:response]
    end

    def create_phone(**optional_params)
      # optional_params: number, name, extension, type, platform, predelay, postdelay
      post('/admin/v1/phones', optional_params)[:response]
    end

    def get_phone(phone_id:)
      get("/admin/v1/phones/#{phone_id}")[:response]
    end

    def update_phone(phone_id:, **optional_params)
      # optional_params: number, name, extension, type, platform, predelay, postdelay
      post("/admin/v1/phones/#{phone_id}", optional_params)[:response]
    end

    def delete_phone(phone_id:)
      delete("/admin/v1/phones/#{phone_id}")[:response]
    end

    def create_activation_url(phone_id:, **optional_params)
      # optional_params: valid_secs, install
      post("/admin/v1/phones/#{phone_id}/activation_url", optional_params)[:response]
    end

    def send_sms_activation(phone_id:, **optional_params)
      # optional_params: valid_secs, install, installation_msg, activation_msg
      post("/admin/v1/phones/#{phone_id}/send_sms_activation", optional_params)[:response]
    end

    def send_sms_installation(phone_id:, **optional_params)
      # optional_params: installation_msg
      post("/admin/v1/phones/#{phone_id}/send_sms_installation", optional_params)[:response]
    end

    def send_sms_passcodes(phone_id:)
      post("/admin/v1/phones/#{phone_id}/send_sms_passcodes")[:response]
    end

    ##
    # Tokens
    #
    def get_tokens(**optional_params)
      # optional_params: type, serial
      get_all('/admin/v1/tokens', optional_params)[:response]
    end

    def create_token(type:, serial:, **optional_params)
      # optional_params: secret, counter, private_id, aes_key
      params = optional_params.merge({ type: type, serial: serial })
      post('/admin/v1/tokens', params)[:response]
    end

    def get_token(token_id:)
      get("/admin/v1/tokens/#{token_id}")[:response]
    end

    def resync_token(token_id:, code1:, code2:, code3:)
      params = { code1: code1, code2: code2, code3: code3 }
      post("/admin/v1/tokens/#{token_id}/resync", params)[:response]
    end

    def delete_token(token_id:)
      delete("/admin/v1/tokens/#{token_id}")[:response]
    end

    ##
    # WebAuthn Credentials
    #
    def get_webauthncredentials
      get_all('/admin/v1/webauthncredentials')[:response]
    end

    def get_webauthncredential(webauthnkey:)
      get("/admin/v1/webauthncredentials/#{webauthnkey}")[:response]
    end

    def delete_webauthncredential(webauthnkey:)
      delete("/admin/v1/webauthncredentials/#{webauthnkey}")[:response]
    end

    ##
    # Desktop Authenticators
    #
    def get_desktop_authenticators
      get_all('/admin/v1/desktop_authenticators')[:response]
    end

    def get_desktop_authenticator(dakey:)
      get("/admin/v1/desktop_authenticators/#{dakey}")[:response]
    end

    def delete_desktop_authenticator(dakey:)
      delete("/admin/v1/desktop_authenticators/#{dakey}")[:response]
    end

    def get_shared_desktop_authenticators
      get_all('/admin/v1/desktop_authenticators/shared_device_auth')[:response]
    end

    def get_shared_desktop_authenticator(shared_device_key:)
      get("/admin/v1/desktop_authenticators/shared_device_auth/#{shared_device_key}")[:response]
    end

    def create_shared_desktop_authenticator(group_id_list:, trusted_endpoint_integration_id_list:,
                                            **optional_params)
      # optional_params: active, name
      params = optional_params.merge({
        group_id_list: group_id_list,
        trusted_endpoint_integration_id_list: trusted_endpoint_integration_id_list
      })
      post('/admin/v1/desktop_authenticators/shared_device_auth', params)[:response]
    end

    def update_shared_desktop_authenticator(shared_device_key:, **optional_params)
      # optional_params: active, name, group_id_list, trusted_endpoint_integration_id_list
      put("/admin/v1/desktop_authenticators/shared_device_auth/#{shared_device_key}",
          optional_params)[:response]
    end

    def delete_shared_desktop_authenticator(shared_device_key:)
      delete("/admin/v1/desktop_authenticators/shared_device_auth/#{shared_device_key}")[:response]
    end

    ##
    # Bypass Codes
    #
    def get_bypass_codes
      get_all('/admin/v1/bypass_codes')[:response]
    end

    def get_bypass_code(bypass_code_id:)
      get("/admin/v1/bypass_codes/#{bypass_code_id}")[:response]
    end

    def delete_bypass_code(bypass_code_id:)
      delete("/admin/v1/bypass_codes/#{bypass_code_id}")[:response]
    end

    ##
    # Integrations
    #
    def get_integrations
      get_all('/admin/v3/integrations')[:response]
    end

    def create_integration(name:, type:, **optional_params)
      # optional_params: adminapi_admins, adminapi_admins_read, adminapi_allow_to_set_permissions,
      #                  adminapi_info, adminapi_integrations, adminapi_read_log,
      #                  adminapi_read_resource, adminapi_settings, adminapi_write_resource,
      #                  enroll_policy, greeting, groups_allowed, ip_whitelist,
      #                  ip_whitelist_enroll_policy, networks_for_api_access, notes,
      #                  trusted_device_days, self_service_allowed, sso, username_normalization_policy
      #
      #      sso params: https://duo.com/docs/adminapi#sso-parameters
      params = optional_params.merge({ name: name, type: type })
      post('/admin/v3/integrations', params)[:response]
    end

    def get_integration(integration_key:)
      get("/admin/v3/integrations/#{integration_key}")[:response]
    end

    def update_integration(integration_key:, **optional_params)
      # optional_params: adminapi_admins, adminapi_admins_read, adminapi_allow_to_set_permissions,
      #                  adminapi_info, adminapi_integrations, adminapi_read_log,
      #                  adminapi_read_resource, adminapi_settings, adminapi_write_resource,
      #                  enroll_policy, greeting, groups_allowed, ip_whitelist,
      #                  ip_whitelist_enroll_policy, networks_for_api_access, notes,
      #                  trusted_device_days, self_service_allowed, sso, username_normalization_policy,
      #                  name, policy_key, prompt_v4_enabled, reset_secret_key
      #
      #      sso params: https://duo.com/docs/adminapi#sso-parameters
      post("/admin/v3/integrations/#{integration_key}", optional_params)[:response]
    end

    def delete_integration(integration_key:)
      delete("/admin/v3/integrations/#{integration_key}")[:response]
    end

    def get_integration_secret_key(integration_key:)
      get("/admin/v1/integrations/#{integration_key}/skey")[:response]
    end

    def get_oauth_integration_client_secret(integration_key:, client_id:)
      get("/admin/v2/integrations/oauth_cc/#{integration_key}/client_secret/#{client_id}")[:response]
    end

    def reset_oauth_integration_client_secret(integration_key:, client_id:)
      post("/admin/v2/integrations/oauth_cc/#{integration_key}/client_secret/#{client_id}")[:response]
    end

    def get_oidc_integration_client_secret(integration_key:)
      get("/admin/v2/integrations/oidc/#{integration_key}/client_secret")[:response]
    end

    def reset_oidc_integration_client_secret(integration_key:)
      post("/admin/v2/integrations/oidc/#{integration_key}/client_secret")[:response]
    end

    ##
    # Policies
    #
    def get_policies_summary
      get('/admin/v2/policies/summary')[:response]
    end

    def get_policies
      get_all('/admin/v2/policies')[:response]
    end

    def get_global_policy
      get('/admin/v2/policies/global')[:response]
    end

    def get_policy(policy_key:)
      get("/admin/v2/policies/#{policy_key}")[:response]
    end

    def calculate_policy(user_id:, integration_key:)
      params = { user_id: user_id, integration_key: integration_key }
      get('/admin/v2/policies/calculate', params)[:response]
    end

    def copy_policy(policy_key:, **optional_params)
      # optional_params: new_policy_names_list
      params = optional_params.merge({ policy_key: policy_key })
      post('/admin/v2/policies/copy', params)[:response]
    end

    def create_policy(policy_name:, **optional_params)
      # optional_params: apply_to_apps, apply_to_groups_in_apps, sections
      params = optional_params.merge({ policy_name: policy_name })
      post('/admin/v2/policies', params)[:response]
    end

    def update_policies(policies_to_update:, policy_changes:)
      # parameter formatting: https://duo.com/docs/adminapi#update-policies
      params = { policies_to_update: policies_to_update, policy_changes: policy_changes }
      put('/admin/v2/policies/update', params)[:response]
    end

    def update_policy(policy_key:, **optional_params)
      # optional_params: apply_to_apps, apply_to_groups_in_apps, sections,
      #                  policy_name, sections_to_delete
      params = optional_params.merge({ policy_key: policy_key })
      put("/admin/v2/policies/#{policy_key}", params)[:response]
    end

    def delete_policy(policy_key:)
      delete("/admin/v2/policies/#{policy_key}")[:response]
    end

    ##
    # Endpoints
    #
    def get_endpoints
      get_all('/admin/v1/endpoints')[:response]
    end

    def get_endpoint(epkey:)
      get("/admin/v1/endpoints/#{epkey}")[:response]
    end

    ##
    # Registered Devices
    #
    def get_registered_devices
      get_all('/admin/v1/registered_devices')[:response]
    end

    def get_registered_device(compkey:)
      get("/admin/v1/registered_devices/#{compkey}")[:response]
    end

    def delete_registered_device(compkey:)
      delete("/admin/v1/registered_devices/#{compkey}")[:response]
    end

    def get_blocked_registered_devices
      get_all('/admin/v1/registered_devices/blocked')[:response]
    end

    def get_blocked_registered_device(compkey:)
      get("/admin/v1/registered_devices/blocked/#{compkey}")[:response]
    end

    def block_registered_devices(registered_device_key_list:)
      params = { registered_device_key_list: registered_device_key_list }
      post('/admin/v1/registered_devices/blocked', params)[:response]
    end

    def block_registered_device(compkey:)
      post("/admin/v1/registered_devices/blocked/#{compkey}")[:response]
    end

    def unblock_registered_devices(registered_device_key_list:)
      params = { registered_device_key_list: registered_device_key_list }
      delete('/admin/v1/registered_devices/blocked', params)[:response]
    end

    def unblock_registered_device(compkey:)
      delete("/admin/v1/registered_devices/blocked/#{compkey}")[:response]
    end

    ##
    # Passport
    #
    def get_passport_config
      get('/admin/v2/passport/config')[:response]
    end

    def update_passport_config(disabled_groups:, enabled_groups:, enabled_status:)
      params = { disabled_groups: disabled_groups, enabled_groups: enabled_groups,
                 enabled_status: enabled_status }
      post('/admin/v2/passport/config', params)[:response]
    end

    ##
    # Administrators
    #
    def get_admins
      get_all('/admin/v1/admins')[:response]
    end

    def create_admin(email:, name:, **optional_params)
      # optional_params: phone, role, restricted_by_admin_units, send_email, token_id, valid_days
      params = optional_params.merge({ email: email, name: name })
      post('/admin/v1/admins', params)[:response]
    end

    def get_admin(admin_id:)
      get("/admin/v1/admins/#{admin_id}")[:response]
    end

    def update_admin(admin_id:, **optional_params)
      # optional_params: phone, role, restricted_by_admin_units, token_id, name, status
      post("/admin/v1/admins/#{admin_id}", optional_params)[:response]
    end

    def delete_admin(admin_id:)
      delete("/admin/v1/admins/#{admin_id}")[:response]
    end

    def reset_admin_auth_attempts(admin_id:)
      post("/admin/v1/admins/#{admin_id}/reset")[:response]
    end

    def clear_admin_inactivity(admin_id:)
      post("/admin/v1/admins/#{admin_id}/clear_inactivity")[:response]
    end

    def create_existing_admin_activation_link(admin_id:)
      post("/admin/v1/admins/#{admin_id}/activation_link")[:response]
    end

    def delete_existing_admin_activation_link(admin_id:)
      delete("/admin/v1/admins/#{admin_id}/activation_link")[:response]
    end

    def email_existing_admin_activation_link(admin_id:)
      post("/admin/v1/admins/#{admin_id}/activation_link/email")[:response]
    end

    def create_new_admin_activation_link(email:, **optional_params)
      # optional_params: admin_name, admin_role, send_email, valid_days
      params = optional_params.merge({ email: email })
      post('/admin/v1/admins/activations', params)[:response]
    end

    def get_new_admin_pending_activations
      get_all('/admin/v1/admins/activations')[:response]
    end

    def delete_new_admin_pending_activations(admin_activation_id:)
      delete("/admin/v1/admins/activations/#{admin_activation_id}")[:response]
    end

    def sync_admin(directory_key:, email:)
      params = { email: email }
      post("/admin/v1/admins/directorysync/#{directory_key}/syncadmin", params)[:response]
    end

    def get_admin_password_mgmt_statuses
      get_all('/admin/v1/admins/password_mgmt')[:response]
    end

    def get_admin_password_mgmt_status(admin_id:)
      get("/admin/v1/admins/#{admin_id}/password_mgmt")[:response]
    end

    def update_admin_password_mgmt_status(admin_id:, **optional_params)
      # optional_params: has_external_password_mgmt, password
      post("/admin/v1/admins/#{admin_id}/password_mgmt", optional_params)[:response]
    end

    def get_admin_allowed_auth_factors
      get('/admin/v1/admins/allowed_auth_methods')[:response]
    end

    def update_admin_allowed_auth_factors(**optional_params)
      # optional_params: hardware_token_enabled, mobile_otp_enabled, push_enabled, sms_enabled,
      #                  verified_push_enabled, verified_push_length, voice_enabled, webauthn_enabled,
      #                  yubikey_enabled
      post('/admin/v1/admins/allowed_auth_methods', optional_params)[:response]
    end

    ##
    # Administrative Units
    #
    def get_administrative_units(**optional_params)
      # optional_params: admin_id, group_id, integration_key
      get_all('/admin/v1/administrative_units', optional_params)[:response]
    end

    def get_administrative_unit(admin_unit_id:)
      get("/admin/v1/administrative_units/#{admin_unit_id}")[:response]
    end

    def create_administrative_unit(name:, description:, restrict_by_groups:, **optional_params)
      # optional_params: restrict_by_integrations, admins, groups, integrations
      params = optional_params.merge({ name: name, description: description,
                                       restrict_by_groups: restrict_by_groups })
      post('/admin/v1/administrative_units', params)[:response]
    end

    def update_administrative_unit(admin_unit_id:, **optional_params)
      # optional_params: restrict_by_integrations, admins, groups, integrations,
      #                  name, description, restrict_by_groups
      post("/admin/v1/administrative_units/#{admin_unit_id}", optional_params)[:response]
    end

    def add_administrative_unit_admin(admin_unit_id:, admin_id:)
      post("/admin/v1/administrative_units/#{admin_unit_id}/admin/#{admin_id}")[:response]
    end

    def remove_administrative_unit_admin(admin_unit_id:, admin_id:)
      delete("/admin/v1/administrative_units/#{admin_unit_id}/admin/#{admin_id}")[:response]
    end

    def add_administrative_unit_group(admin_unit_id:, group_id:)
      post("/admin/v1/administrative_units/#{admin_unit_id}/group/#{group_id}")[:response]
    end

    def remove_administrative_unit_group(admin_unit_id:, group_id:)
      delete("/admin/v1/administrative_units/#{admin_unit_id}/group/#{group_id}")[:response]
    end

    def add_administrative_unit_integration(admin_unit_id:, integration_key:)
      post("/admin/v1/administrative_units/#{admin_unit_id}/integration/#{integration_key}")[:response]
    end

    def remove_administrative_unit_integration(admin_unit_id:, integration_key:)
      delete("/admin/v1/administrative_units/#{admin_unit_id}/integration/#{integration_key}")[:response]
    end

    def delete_administrative_unit(admin_unit_id:)
      delete("/admin/v1/administrative_units/#{admin_unit_id}")[:response]
    end

    ##
    # Logs
    #
    def get_authentication_logs(mintime:, maxtime:, **optional_params)
      # optional_params: applications, users, assessment, detections, event_types, factors, formatter,
      #                  groups, phone_numbers, reasons, results, tokens, sort
      #
      #       more info: https://duo.com/docs/adminapi#authentication-logs
      params = optional_params.merge({ mintime: mintime, maxtime: maxtime })
      data_array_path = %i[response authlogs]
      metadata_path = %i[response metadata]
      get_all('/admin/v2/logs/authentication', params, data_array_path: data_array_path,
              metadata_path: metadata_path).dig(*data_array_path)
    end

    def get_activity_logs(mintime:, maxtime:, **optional_params)
      # optional_params: sort
      params = optional_params.merge({ mintime: mintime, maxtime: maxtime })
      data_array_path = %i[response items]
      metadata_path = %i[response metadata]
      get_all('/admin/v2/logs/activity', params, data_array_path: data_array_path,
              metadata_path: metadata_path).dig(*data_array_path)
    end

    def get_admin_logs(**optional_params)
      # optional_params: mintime
      get('/admin/v1/logs/administrator', optional_params)[:response]
    end

    def get_telephony_logs(mintime:, maxtime:, **optional_params)
      # optional_params: sort
      params = optional_params.merge({ mintime: mintime, maxtime: maxtime })
      data_array_path = %i[response items]
      metadata_path = %i[response metadata]
      get_all('/admin/v2/logs/telephony', params, data_array_path: data_array_path,
              metadata_path: metadata_path).dig(*data_array_path)
    end

    def get_offline_enrollment_logs(**optional_params)
      # optional_params: mintime
      get('/admin/v1/logs/offline_enrollment', optional_params)[:response]
    end

    ##
    # Trust Monitor
    #
    def get_trust_monitor_events(mintime:, maxtime:, **optional_params)
      # optional_params: formatter, type
      params = optional_params.merge({ mintime: mintime, maxtime: maxtime })
      params[:limit] = 200 if !params[:limit] || (params[:limit].to_i > 200)
      data_array_path = %i[response events]
      metadata_path = %i[response metadata]
      get_all('/admin/v1/trust_monitor/events', params, data_array_path: data_array_path,
              metadata_path: metadata_path).dig(*data_array_path)
    end

    ##
    # Settings
    #
    def get_settings
      get('/admin/v1/settings')[:response]
    end

    def update_settings(**optional_params)
      # optional_params: caller_id, duo_mobile_otp_type, email_activity_notification_enabled,
      #                  enrollment_universal_prompt_enabled, fraud_email, fraud_email_enabled,
      #                  global_ssp_policy_enforced, helpdesk_bypass, helpdesk_bypass_expiration,
      #                  helpdesk_can_send_enroll_email, inactive_user_expiration, keypress_confirm,
      #                  keypress_fraud, language, lockout_expire_duration, lockout_threshold,
      #                  log_retention_days, minimum_password_length, name,
      #                  password_requires_lower_alpha, password_requires_numeric,
      #                  password_requires_special, password_requires_upper_alpha,
      #                  push_activity_notification_enabled, sms_batch, sms_expiration, sms_message,
      #                  sms_refresh, telephony_warning_min, timezone, unenrolled_user_lockout_threshold,
      #                  user_managers_can_put_users_in_bypass, user_telephony_cost_max
      post('/admin/v1/settings', optional_params)[:response]
    end

    def get_logo
      get_image('/admin/v1/logo')
    end

    def update_logo(logo:)
      # logo should be raw png data or base64 strict encoded raw png data
      encoded_logo = base64?(logo) ? logo : Base64.strict_encode64(logo)
      params = { logo: encoded_logo }
      post('/admin/v1/logo', params)[:response]
    end

    def delete_logo
      delete('/admin/v1/logo')[:response]
    end

    ##
    # Custom Branding
    #
    def get_custom_branding
      get('/admin/v1/branding')[:response]
    end

    def update_custom_branding(**optional_params)
      # optional_params: background_img, card_accent_color, logo, page_background_color,
      #                  powered_by_duo, sso_custom_username_label
      post('/admin/v1/branding', optional_params)[:response]
    end

    def get_custom_branding_draft
      get('/admin/v1/branding/draft')[:response]
    end

    def update_custom_branding_draft(**optional_params)
      # optional_params: background_img, card_accent_color, logo, page_background_color,
      #                  powered_by_duo, sso_custom_username_label, user_ids
      post('/admin/v1/branding/draft', optional_params)[:response]
    end

    def add_custom_branding_draft_user(user_id:)
      post("/admin/v1/branding/draft/users/#{user_id}")[:response]
    end

    def remove_custom_branding_draft_user(user_id:)
      delete("/admin/v1/branding/draft/users/#{user_id}")[:response]
    end

    def publish_custom_branding_draft
      post('/admin/v1/branding/draft/publish')[:response]
    end

    def get_custom_branding_messaging
      get('/admin/v1/branding/custom_messaging')[:response]
    end

    def update_custom_branding_messaging(**optional_params)
      # optional_params: help_links, help_text, locale
      post('/admin/v1/branding/custom_messaging', optional_params)[:response]
    end

    ##
    # Account Info
    #
    def get_account_info_summary
      get('/admin/v1/info/summary')[:response]
    end

    def get_telephony_credits_used_report(**optional_params)
      # optional_params: maxtime, mintime
      get('/admin/v1/info/telephony_credits_used', optional_params)[:response]
    end

    def get_authentication_attempts_report(**optional_params)
      get('/admin/v1/info/authentication_attempts', optional_params)[:response]
    end

    def get_user_authentication_attempts_report(**optional_params)
      get('/admin/v1/info/user_authentication_attempts', optional_params)[:response]
    end

    private

    def serialized_aliases(aliases)
      case aliases
      when Array
        aliases.map.with_index{ |a, i| "alias#{i + 1}=#{a}" }.join('&')
      when Hash
        aliases.map{ |k, v| "#{k}=#{v}" }.join('&')
      else
        aliases
      end
    end
  end
end
