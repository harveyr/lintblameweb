angular.module(SERVICE_MODULE).service 'LocalStorage', () ->
    class LocalStorage
        STORAGE_KEY: 'lintblame'
        SAVED_BUNDLES_KEY: 'saves'

        listeners: []

        set: (val) ->
            localStorage.setItem @STORAGE_KEY, JSON.stringify val
            _.each @listeners, (listener) ->
                listener()

        setAttr: (key, val) ->
            all = @get()
            all[key] = val
            @set all

        get: (key=null) ->
            all = JSON.parse(localStorage.getItem @STORAGE_KEY)
            if not key
                return all
            all[key]

        _setSavedLintBundles: (saved) ->
            @setAttr @SAVED_BUNDLES_KEY, saved
            
        savedLintBundles: ->
            @get @SAVED_BUNDLES_KEY

        saveLintBundle: (lintBundle) ->
            currentSaved = @get @SAVED_BUNDLES_KEY
            path = lintBundle.fullPath
            if not path
                throw "LocalStorage.saveLintBundle(): Bad path: #{path}"
            lintBundle.updated = Date.now()
            currentSaved[path] = lintBundle
            @_setSavedLintBundles currentSaved

        savedLintBundle: (path) ->
            @savedLintBundles()[path]

        setSaveName: (path, name) ->
            bundle = @savedLintBundle path
            bundle.saveName = name
            @saveLintBundle bundle

        deleteSave: (path) ->
            saved = @savedLintTargets()
            if _.has saved, path
                delete saved[path]
            @_setSavedLintBundles saved

        resetAppStorage: ->
            console.log 'resetting app storage'
            defaultState = {}
            defaultState[@SAVED_BUNDLES_KEY] = {}
            @set defaultState

        initIfNecessary: ->
            if not @get()
                @resetAppStorage()

        addListener: (listener) ->
            @listeners.push listener


    new LocalStorage()
