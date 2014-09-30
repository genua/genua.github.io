---
layout: post
author: matthias_geier
title: "Rails 4.0 - Devise 3.0.1 - CSRF token robustness prevents redirection"
description: "Every use consumes the CSRF token and therefore leads to
  a warning that prevents redirection or fails on custom forms"
category: Devise
tags: [rails4.0, devise3.0.1, csrf, crsf-token-authenticity]
---
{% include JB/setup %}

Since Devise 3.0.1 the CSRF token by default is consumed after first use
and therefore it breaks the Rails internal redirection when using custom
forms. The change is based on OpenID suggestions to make CSRF more robust.

Unfortunately this leads only to a small warning in the Rails server
console which could mean alot of things:

    WARNING: Can’t verify CSRF token authenticity

Amongst other things, this may be resolved in two ways, should the error
occur when using redirection and custom forms:

1) Add a condition so the protection will only trigger when using a different
route:

    class MyController < ActionController::Base
      protect_from_forgery :except => :index

      # alternative
      skip_before_filter :verify_authenticity_token, :except => :index

      def index
        render 'foo'
      end
    end

2) Disable the consumption of the CRSF token in Devise and restore the old
behaviour until a decent fix is provided either through Devise or Rails:

    Devise.setup do |config|
      config.clean_up_csrf_token_on_authentication = false
    end

Resources:
- *http://blog.plataformatec.com.br/2013/08/csrf-token-fixation-attacks-in-devise/*
