{% set base_app = 'oscarcommerce_base' %}
{% set project_name = salt['pillar.get']('project_name') %}


params_env:
    cmd.run:
        - name: 
            echo
            \\n base_app = {{ base_app }}
            \\n project_name = {{ project_name }}


#
# env
#
#   * update
#       * apt-get update && apt-get upgrade
#   * init
#       * install packages
#           * base_app
#           * project-specific (if exist)

# update
{{ project_name }}_apt_update:
    pkg.uptodate:
        - refresh: true

# init
{{ base_app }}_apt_packages_init:
    pkg.installed:
        - pkgs:
            {% for package in salt['pillar.get'](base_app + ':packages') %}
            - {{ package }}
            {% endfor %}

{% if salt['pillar.get'](project_name + ':packages') != '' %}

{{ project_name }}_apt_packages_init:
    pkg.installed:
        - pkgs:
            {% for package in salt['pillar.get'](project_name + ':packages') %}
            - {{ package }}
            {% endfor %}

{% endif %}
