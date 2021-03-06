require 'fastlane_core'
require 'credentials_manager'

module Produce
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "PRODUCE_USERNAME",
                                     description: "Your Apple ID Username",
                                     code_gen_sensitive: true,
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     env_name: "PRODUCE_APP_IDENTIFIER",
                                     short_option: "-a",
                                     description: "App Identifier (Bundle ID, e.g. com.krausefx.app)",
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :bundle_identifier_suffix,
                                     short_option: "-e",
                                     env_name: "PRODUCE_APP_IDENTIFIER_SUFFIX",
                                     optional: true,
                                     description: "App Identifier Suffix (Ignored if App Identifier does not end with .*)"),
        FastlaneCore::ConfigItem.new(key: :app_name,
                                     env_name: "PRODUCE_APP_NAME",
                                     short_option: "-q",
                                     description: "App Name"),
        FastlaneCore::ConfigItem.new(key: :app_version,
                                     short_option: "-z",
                                     optional: true,
                                     env_name: "PRODUCE_VERSION",
                                     description: "Initial version number (e.g. '1.0')"),
        FastlaneCore::ConfigItem.new(key: :sku,
                                     env_name: "PRODUCE_SKU",
                                     short_option: "-y",
                                     description: "SKU Number (e.g. '1234')",
                                     code_gen_sensitive: true,
                                     default_value: Time.now.to_i.to_s,
                                     is_string: true),
        FastlaneCore::ConfigItem.new(key: :platform,
                                     short_option: "-j",
                                     env_name: "PRODUCE_PLATFORM",
                                     description: "The platform to use (optional)",
                                     optional: true,
                                     default_value: "ios",
                                     verify_block: proc do |value|
                                                     UI.user_error!("The platform can only be ios or osx") unless %('ios', 'osx').include? value
                                                   end),
        FastlaneCore::ConfigItem.new(key: :language,
                                     short_option: "-m",
                                     env_name: "PRODUCE_LANGUAGE",
                                     description: "Primary Language (e.g. 'English', 'German')",
                                     default_value: "English",
                                     verify_block: proc do |language|
                                     end),
        FastlaneCore::ConfigItem.new(key: :company_name,
                                     short_option: "-c",
                                     env_name: "PRODUCE_COMPANY_NAME",
                                     description: "The name of your company. Only required if it's the first app you create",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_itc,
                                     short_option: "-i",
                                     env_name: "PRODUCE_SKIP_ITC",
                                     description: "Skip the creation of the app on iTunes Connect",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :itc_users,
                                     short_option: "-s",
                                     env_name: "ITC_USERS",
                                     optional: true,
                                     type: Array,
                                     description: "Array of iTunes Connect users. If provided, you can limit access to this newly created app for users with the App Manager, Developer, Marketer or Sales roles",
                                     is_string: false),
        # Deprecating this in favor of a rename from "enabled_features" to "enable_services"
        FastlaneCore::ConfigItem.new(key: :enabled_features,
                                     deprecated: "Please use `enable_services` instead",
                                     display_in_shell: false,
                                     env_name: "PRODUCE_ENABLED_FEATURES",
                                     description: "Array with Spaceship App Services",
                                     is_string: false,
                                     default_value: {},
                                     verify_block: proc do |value|
                                                     allowed_keys = Produce::DeveloperCenter::ALLOWED_SERVICES.keys
                                                     UI.user_error!("enabled_features has to be of type Hash") unless value.kind_of?(Hash)
                                                     value.each do |key, v|
                                                       UI.user_error!("The key: '#{key}' is not supported in `enabled_features' - following keys are available: [#{allowed_keys.join(',')}]") unless allowed_keys.include? key.to_sym
                                                     end
                                                   end),
        FastlaneCore::ConfigItem.new(key: :enable_services,
                                     display_in_shell: false,
                                     env_name: "PRODUCE_ENABLE_SERVICES",
                                     description: "Array with Spaceship App Services (e.g. #{allowed_services_description})",
                                     is_string: false,
                                     default_value: {},
                                     verify_block: proc do |value|
                                                     allowed_keys = Produce::DeveloperCenter::ALLOWED_SERVICES.keys
                                                     UI.user_error!("enable_services has to be of type Hash") unless value.kind_of?(Hash)
                                                     value.each do |key, v|
                                                       UI.user_error!("The key: '#{key}' is not supported in `enable_services' - following keys are available: [#{allowed_keys.join(',')}]") unless allowed_keys.include? key.to_sym
                                                     end
                                                   end),

        FastlaneCore::ConfigItem.new(key: :skip_devcenter,
                                     short_option: "-d",
                                     env_name: "PRODUCE_SKIP_DEVCENTER",
                                     description: "Skip the creation of the app on the Apple Developer Portal",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "PRODUCE_TEAM_ID",
                                     description: "The ID of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "PRODUCE_TEAM_NAME",
                                     description: "The name of your Developer Portal team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :itc_team_id,
                                     short_option: "-k",
                                     env_name: "PRODUCE_ITC_TEAM_ID",
                                     description: "The ID of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     is_string: false, # as we also allow integers, which we convert to strings anyway
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :itc_team_name,
                                     short_option: "-p",
                                     env_name: "PRODUCE_ITC_TEAM_NAME",
                                     description: "The name of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                     end)
      ]
    end

    def self.allowed_services_description
      return Produce::DeveloperCenter::ALLOWED_SERVICES.map do |k, v|
        "#{k}: (#{v.join('|')})"
      end.join(", ")
    end
  end
end
