from settings import *


#
# debug
#
DEBUG = True

INSTALLED_APPS += [
    'debug_toolbar',
    'django.contrib.admin',
]

MIDDLEWARE = [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
] + MIDDLEWARE

INTERNAL_IPS = ('127.0.0.1')

