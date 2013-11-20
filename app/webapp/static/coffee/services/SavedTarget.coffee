angular.module(SERVICE_MODULE).service 'SavedTarget', () ->
    class SavedTarget
        constructor: (properties) ->
            defaults =
                branchMode: false

            properties = _.extend defaults, properties
            _.each properties, (val, key) =>
                @[key] = val

        toObj: ->
            {
                path: @path,
                branchMode: @branchMode,
                updated: @updated,
                saveName: @saveName
            }

        setUpdated: ->
            @updated = Date.now()

    SavedTarget
