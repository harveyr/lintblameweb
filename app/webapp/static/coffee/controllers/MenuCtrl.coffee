angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, $q, Api, LocalStorage) ->
    $scope.showSubmitBtn = true
    $scope.isPolling = false
    $scope.pollCount = 0
    $rootScope.acceptedLintPath = null
    $scope.pendingPaths = []
    $rootScope.resetLintBundle()
    $scope.showSaves = false

    testPath = (andAccept=false) ->
        deferred = $q.defer()
        path = $scope.targetPathInput
        Api.testPath(path, $rootScope.lintBundle.branchMode).then (response) ->
            $scope.pathExists = response.exists
            $scope.fullPath = response.path
            $scope.targets = response.targets

            if not _.isUndefined response.vcs
                $scope.vcs = response.vcs
                $scope.branch = response.branch
                $rootScope.vcsName = response.name

            if andAccept
                $scope.acceptPath()
            deferred.resolve()
        deferred.promise

    stopPolling = ->
        if $scope.pollInterval
            clearInterval($scope.pollInterval)
        $scope.isPolling = false

    showSaveBtn = ->
        $scope.showSaveBtn = true
        $scope.showSubmitBtn = false

    hideSaveBtn = ->
        $scope.showSaveBtn = false

    $scope.startPolling = ->
        stopPolling()
        $scope.isPolling = true

        $scope.pollInterval = setInterval ->
            thresholdPaths = $scope.targets

            fullScan = thresholdPaths.length and !$rootScope.activePaths().length
            if thresholdPaths.length > 0
                $rootScope.noPaths = false
                Api.poll(
                    [$rootScope.lintBundle.fullPath],
                    $rootScope.lintBundle.branchMode,
                    fullScan
                ).then (response) ->
                    if not _.isEmpty response
                        $rootScope.updateResults response.changed
                        # This isn't working correctly
                        # if _.has response, 'delete'
                        #     for p in response.delete
                        #         $rootScope.deletePath p
                $scope.pollCount += 1
            else
                $rootScope.noPaths = true
                console.log 'not polling because no paths'
        , 2000

    $scope.togglePolling = ->
        if $scope.isPolling
            stopPolling()
        else
            $scope.startPolling()
        $rootScope.updateLintBundle {'isPolling': $scope.isPolling}

    $scope.acceptPath = ->
        if !$scope.targets or $scope.targets.length == 0
            console.log 'no targets; aborting'
            return
        showSaveBtn()
        $rootScope.updateLintBundle {
            'inputPath': $scope.targetPathInput
            'fullPath': $scope.fullPath
        }
        $scope.startPolling()

    targetPathChange = ->
        stopPolling()
        path = $scope.targetPathInput
        if path
            $rootScope.resetLintBundle()
            $scope.showSubmitBtn = true
            testPath()
    $scope.targetPathChange = _.throttle(targetPathChange, 1000)


    $scope.toggleBranchMode = ->
        $rootScope.lintBundle.branchMode = !$rootScope.lintBundle.branchMode
        $rootScope.saveCurrentBundle()
        testPath(true)


    $scope.saveState = ->
        properties = 
            path: $rootScope.acceptedLintPath
            branchMode: $rootScope.branchMode
        save = new SavedTarget(properties)
        LocalStorage.saveLintTarget save
        hideSaveBtn()

    loadSave = (path) ->
        if not path
            return
        $rootScope.resetLintBundle()
        savedBundle = LocalStorage.savedLintBundle path
        savedBundle.lints = {}
        $rootScope.lintBundle = savedBundle
        $scope.targetPathInput = path
        $rootScope.acceptedLintPath = path
        testPath(true)
        $scope.showSaveBtn = false

    updateSaves = ->
        $scope.saves = LocalStorage.savedLintBundles()
        paths = _.keys $scope.saves
        $scope.sortedSavePaths = paths.sort (a, b) ->
            return $scope.saves[b].updated - $scope.saves[a].updated


    LocalStorage.addListener ->
        updateSaves()

    $scope.loadSavePath = (path) ->
        $rootScope.loadedSavePath = path
        $scope.showSaves = false
        loadSave $rootScope.loadedSavePath

    # Init
    updateSaves()

