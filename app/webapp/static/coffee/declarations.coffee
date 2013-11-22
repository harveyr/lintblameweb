APP_NAME = 'lintblame'
DIRECTIVE_MODULE = "#{APP_NAME}.directives"
SERVICE_MODULE = "#{APP_NAME}.services"
angular.module(DIRECTIVE_MODULE, [])
angular.module(SERVICE_MODULE, [])

_.mixin {
    dget: (obj, key, default_) ->
        if _.has obj, key
            return obj[key]
        return default_
}
