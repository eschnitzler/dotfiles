local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node

return {
  -- Block tags
  s("block", {
    t("{% block "), i(1, "name"), t(" %}"),
    t({ "", "\t" }), i(2),
    t({ "", "{% endblock " }), i(3, "name"), t(" %}"),
  }),

  s("extends", {
    t('{% extends "'), i(1, "base.html"), t('" %}'),
  }),

  s("include", {
    t('{% include "'), i(1, "template.html"), t('" %}'),
  }),

  -- Control flow
  s("if", {
    t("{% if "), i(1, "condition"), t(" %}"),
    t({ "", "\t" }), i(2),
    t({ "", "{% endif %}" }),
  }),

  s("ife", {
    t("{% if "), i(1, "condition"), t(" %}"),
    t({ "", "\t" }), i(2),
    t({ "", "{% else %}" }),
    t({ "", "\t" }), i(3),
    t({ "", "{% endif %}" }),
  }),

  s("elif", {
    t("{% elif "), i(1, "condition"), t(" %}"),
  }),

  s("for", {
    t("{% for "), i(1, "item"), t(" in "), i(2, "items"), t(" %}"),
    t({ "", "\t" }), i(3),
    t({ "", "{% endfor %}" }),
  }),

  s("empty", t("{% empty %}")),

  -- Variables and filters
  s("var", {
    t("{{ "), i(1, "variable"), t(" }}"),
  }),

  s("static", {
    t('{% static "'), i(1, "path"), t('" %}'),
  }),

  s("url", {
    t('{% url "'), i(1, "name"), t('" '), i(2, "args"), t(" %}"),
  }),

  -- Comments
  s("comment", {
    t("{% comment %}"),
    t({ "", "\t" }), i(1, "comment"),
    t({ "", "{% endcomment %}" }),
  }),

  s("{#", {
    t("{# "), i(1, "comment"), t(" #}"),
  }),

  -- Common filters
  s("default", {
    t("{{ "), i(1, "variable"), t("|default:"), i(2, '""'), t(" }}"),
  }),

  s("safe", {
    t("{{ "), i(1, "variable"), t("|safe }}"),
  }),

  s("length", {
    t("{{ "), i(1, "variable"), t("|length }}"),
  }),

  s("date", {
    t("{{ "), i(1, "variable"), t('|date:"'), i(2, "Y-m-d"), t('" }}'),
  }),

  -- CSRF and forms
  s("csrf", t("{% csrf_token %}")),

  s("form", {
    t("{{ "), i(1, "form"), t(".as_p }}"),
  }),

  -- Template utilities
  s("load", {
    t("{% load "), i(1, "static"), t(" %}"),
  }),

  s("with", {
    t("{% with "), i(1, "var"), t("="), i(2, "value"), t(" %}"),
    t({ "", "\t" }), i(3),
    t({ "", "{% endwith %}" }),
  }),

  s("autoescape", {
    t("{% autoescape "), i(1, "on"), t(" %}"),
    t({ "", "\t" }), i(2),
    t({ "", "{% endautoescape %}" }),
  }),

  -- Template inheritance common patterns
  s("base", {
    t("<!DOCTYPE html>"),
    t({ "", "<html lang=\"en\">" }),
    t({ "", "<head>" }),
    t({ "", "    <meta charset=\"UTF-8\">" }),
    t({ "", "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" }),
    t({ "", "    <title>{% block title %}" }), i(1, "Page Title"), t("{% endblock %}</title>"),
    t({ "", "    {% block extra_head %}{% endblock %}" }),
    t({ "", "</head>" }),
    t({ "", "<body>" }),
    t({ "", "    {% block content %}" }),
    t({ "", "    {% endblock %}" }),
    t({ "", "    {% block extra_js %}{% endblock %}" }),
    t({ "", "</body>" }),
    t({ "", "</html>" }),
  }),
}
