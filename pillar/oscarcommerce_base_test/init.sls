oscarcommerce_base_test:
    options:
        is_env_apply: True
        is_lib_apply: True
        is_opt_apply: True
        is_db_apply: True
        is_webserver_apply: True
    allowed_hosts:
        - 127.0.0.1
        - oscarcommerce-base-test.com
        - www.oscarcommerce-base-test.com
    postgresql:
        user: oscarcommerce_base_test
        name: oscarcommerce_base_test
        pass: test
    nginx:
        server_name:
            - oscarcommerce-base-test.com
            - www.oscarcommerce-base-test.com
    gunicorn:
        num_workers: 9
