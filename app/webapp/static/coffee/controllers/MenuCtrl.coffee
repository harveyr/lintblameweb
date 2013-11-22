angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, $q, Api, LocalStorage) ->
    $scope.showSubmitBtn = true
    $scope.isPolling = false
    $scope.pollCount = 0
    $rootScope.acceptedLintPath = null
    $scope.pendingPaths = []
    $rootScope.resetLintBundle()

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

        $scope.pollInterval = setInterval ->
            paths = $rootScope.activePaths()
            if paths.length > 0
                Api.poll(
                    [$rootScope.acceptedLintPath],
                    $rootScope.lintBundle.branchMode
                ).then (response) ->
                    if not _.isEmpty response
                        $rootScope.updateResults response.changed
                        # This isn't working correctly
                        # if _.has response, 'delete'
                        #     for p in response.delete
                        #         $rootScope.deletePath p
                $scope.pollCount += 1
            else
                console.log 'not polling because no paths'
        , 2000
        $scope.isPolling = true

    $scope.togglePolling = ->
        if $scope.isPolling
            stopPolling()
        else
            $scope.startPolling()
        $rootScope.updateLintBundle 'isPolling', $scope.isPolling

    $scope.acceptPath = ->
        if !$scope.targets or $scope.targets.length == 0
            console.log 'no targets; aborting'
            return
        showSaveBtn()
        $rootScope.updateLintBundle {
            'inputPath': $scope.targetPathInput
            'fullPath': $scope.fullPath
        }

        Api.fullScan($scope.targets).then (response) ->
            $rootScope.updateResults response

    targetPathChange = ->
        stopPolling()
        path = $scope.targetPathInput
        if path
            $rootScope.resetLintBundle()
            $scope.showSubmitBtn = true
            testPath()
    $scope.targetPathChange = _.throttle(targetPathChange, 1000)


    $scope.toggleBranchMode = ->
        $rootScope.toggleBranchMode()
        testPath(true)
        showSaveBtn()

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
        $rootScope.lintBundle = savedBundle
        $scope.targetPathInput = path
        $rootScope.acceptedLintPath = path
        testPath(true)
        $scope.showSaveBtn = false

    $scope.$watch 'loadedSavePath', ->
        loadSave $rootScope.loadedSavePath
