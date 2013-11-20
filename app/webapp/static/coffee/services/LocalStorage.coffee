angular.module(SERVICE_MODULE).service 'LocalStorage', (SavedTarget) ->
    class LocalStorage
        STORAGE_KEY: 'lintblame'
        SAVED_TARGETS_KEY: 'saves'

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

        savedLintTargets: ->
            @get @SAVED_TARGETS_KEY

        updateSavedLintTargets: (saved) ->
            @setAttr @SAVED_TARGETS_KEY, saved
            

        saveLintTarget: (saveTarget) ->
            currentSaved = @get @SAVED_TARGETS_KEY
            path = saveTarget.path
            if not path
                throw "Bad path: #{path}"
            saveTarget.setUpdated()
            currentSaved[path] = saveTarget.toObj()
            @updateSavedLintTargets currentSaved

        getSavedLintTarget: (path) ->
            saved = @savedLintTargets()
            if _.has saved, path
                target = new SavedTarget(saved[path])
                return target
            throw "#{path} is not saved!"

        setSaveName: (path, name) ->
            target = @getSavedLintTarget path
            target.saveName = name
            @saveLintTarget target

        deleteSave: (path) ->
            saved = @savedLintTargets()
            if _.has saved, path
                delete saved[path]
            @updateSavedLintTargets saved

        resetAppStorage: ->
            console.log 'resetting app storage'
            defaultState = {}
            defaultState[@SAVED_TARGETS_KEY] = {}
            @set defaultState

        initIfNecessary: ->
            if not @get()
                @resetAppStorage()

        addListener: (listener) ->
            @listeners.push listener


    new LocalStorage()
