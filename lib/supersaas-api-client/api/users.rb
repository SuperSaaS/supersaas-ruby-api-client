# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/user_api
  class Users < BaseApi
    def list(form = nil, limit = nil, offset = nil)
      path = user_path(nil)
      params = {
        form: form ? true : nil,
        limit: limit ? validate_number(limit) : nil,
        offset: offset ? validate_number(offset) : nil
      }.compact

      res = client.get(path, params)
      return [] if res.nil?

      res.map { |attributes| Supersaas::User.new(attributes) }
    end

    def get(user_id, form = nil)
      path = user_path(user_id)
      params = {form: form ? true : nil}.compact
      res = client.get(path, params)

      Supersaas::User.new(res)
    end

    def create(attributes, user_id = nil, webhook = nil, duplicate = nil)
      path = user_path(user_id)
      query_params = {webhook: webhook}
      query_params[:duplicate] = validate_duplicate(duplicate) if duplicate

      params = {user: build_user_attributes(attributes)}
      client.post(path, params, query_params.compact)
    end

    def update(user_id, attributes, webhook = nil, notfound = nil)
      path = user_path(user_id)
      query_params = {webhook: webhook}
      query_params[:notfound] = validate_notfound(notfound) if notfound

      params = {user: build_user_attributes(attributes)}
      client.put(path, params, query_params.compact)
    end

    def delete(user_id, webhook = nil)
      path = user_path(user_id)
      params = {webhook: webhook}
      client.delete(path, nil, params)
    end

    def field_list
      path = "/field_list"
      res = client.get(path)
      return [] if res.nil?

      res.map { |attributes| Supersaas::FieldList.new(attributes) }
    end

    private

    def user_path(user_id)
      if user_id.nil? || user_id == ""
        "/users"
      else
        "/users/#{validate_user(user_id)}"
      end
    end

    def build_user_attributes(attributes)
      {
        name: validate_name(attributes[:name]),
        email: attributes[:email],
        password: attributes[:password],
        full_name: attributes[:full_name],
        address: attributes[:address],
        mobile: attributes[:mobile],
        phone: attributes[:phone],
        country: attributes[:country],
        timezone: attributes[:timezone],
        field_1: attributes[:field_1],
        field_2: attributes[:field_2],
        super_field: attributes[:super_field],
        credit: attributes[:credit] ? validate_number(attributes[:credit]) : nil,
        role: attributes[:role] ? validate_options(attributes[:role], User::ROLES) : nil,
        group: attributes[:group] ? validate_number(attributes[:group]) : nil
      }.compact
    end
  end
end
