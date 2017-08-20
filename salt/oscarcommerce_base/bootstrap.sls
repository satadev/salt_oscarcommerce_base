#
# params
#
# * get required parameters (commandline)
# * get bypass options
#   - these act as on/off switches which determine which
#       states are applied.  the values are set according
#       to the following progression with the first existing
#       value taking precedence:
#           -> commandline
#           -> pillar
#           -> default value or error

{% set base_app = 'oscarcommerce_base' %}
{% set admin_user = salt['pillar.get']('admin_user') %}
{% set project_name = salt['pillar.get']('project_name') %}

# options
{% if salt['pillar.get']('is_env_apply') != '' %}
    {% set is_env_apply = salt['pillar.get']('is_env_apply') %}
{% else %}
    {% set is_env_apply = salt['pillar.get'](project_name + ':options:is_env_apply', False) %}
{% endif %}

{% if salt['pillar.get']('is_lib_apply') != '' %}
    {% set is_lib_apply = salt['pillar.get']('is_lib_apply') %}
{% else %}
    {% set is_lib_apply = salt['pillar.get'](project_name + ':options:is_lib_apply', False) %}
{% endif %}

{% if salt['pillar.get']('is_opt_apply') != '' %}
    {% set is_opt_apply = salt['pillar.get']('is_opt_apply') %}
{% else %}
    {% set is_opt_apply = salt['pillar.get'](project_name + ':options:is_opt_apply', False) %}
{% endif %}

{% if salt['pillar.get']('is_db_apply') != '' %}
    {% set is_db_apply = salt['pillar.get']('is_db_apply') %}
{% else %}
    {% set is_db_apply = salt['pillar.get'](project_name + ':options:is_db_apply', False) %}
{% endif %}

{% if salt['pillar.get']('is_webserver_apply') != '' %}
    {% set is_webserver_apply = salt['pillar.get']('is_webserver_apply') %}
{% else %}
    {% set is_webserver_apply = salt['pillar.get'](project_name + ':options:is_webserver_apply', False) %}
{% endif %}

# params debug
params:
    cmd.run:
        - name: 
            echo 
            \\n base_app = {{ base_app }}
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n is_env_apply = {{ is_env_apply }}
            \\n is_lib_apply = {{ is_lib_apply }}
            \\n is_opt_apply = {{ is_opt_apply }}
            \\n is_db_apply = {{ is_db_apply }}
            \\n is_webserver_apply = {{ is_webserver_apply }}


{% if is_env_apply %}
    {% include '/srv/salt/' + base_app + '/bootstrap_env.sls' %}
{% endif %}

{% if is_lib_apply %}
    {% include '/srv/salt/' + base_app + '/bootstrap_lib.sls' %}
{% endif %}

{% if is_opt_apply %}
    {% include '/srv/salt/' + base_app + '/bootstrap_opt.sls' %}
{% endif %}

{% if is_db_apply %}
    {% include '/srv/salt/' + base_app + '/bootstrap_db.sls' %}
{% endif %}

{% if is_webserver_apply %}
    {% include '/srv/salt/' + base_app + '/bootstrap_webserver.sls' %}
{% endif %}
