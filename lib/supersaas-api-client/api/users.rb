# frozen_string_literal: true

module Supersaas
  # REF: https://www.supersaas.com/info/dev/user_api
  class Users < BaseApi
    def list(form = nil, limit = nil, offset = nil)
      path = user_path(nil)
      params = {
        form: form ? true : nil,
        limit: limit && validate_number(limit),
        offset: offset && validate_number(offset)
      }
      res = client.get(path, params)
      res.map { |attributes| Supersaas::User.new(attributes) }
    end

    def get(user_id)
      path = user_path(user_id)
      res = client.get(path)
      Supersaas::User.new(res)
    end

    def create(attributes, user_id = nil, webhook = nil, duplicate = nil)
      path = user_path(user_id)
      query = { webhook: webhook }
      query.merge!(duplicate: validate_duplicate(duplicate)) if duplicate
      params = {
        user: {
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
          credit: attributes[:credit] && validate_number(attributes[:credit]),
          role: attributes[:role] && validate_options(attributes[:role], User::ROLES)
        }
      }
      client.post(path, params, query)
    end

    def update(user_id, attributes, webhook = nil, notfound = nil)
      path = user_path(user_id)
      query = { webhook: webhook }
      query.merge!(notfound: validate_notfound(notfound)) if notfound
      params = {
        user: {
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
          credit: attributes[:credit] && validate_number(attributes[:credit]),
          role: attributes[:role] && validate_options(attributes[:role], User::ROLES)
        }
      }
      params[:user].compact!
      client.put(path, params, query)
    end

    def delete(user_id)
      path = user_path(user_id)
      client.delete(path)
    end

    def field_list
      path = '/field_list'
      res = client.get(path)
      res.map { |attributes| Supersaas::FieldList.new(attributes) }
    end

    private

    def user_path(user_id)
      if user_id.nil? || user_id == ''
        '/users'
      else
        "/users/#{validate_user(user_id)}"
      end
    end
  end
end
