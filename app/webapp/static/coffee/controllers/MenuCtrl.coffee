angular.module(APP_NAME).controller 'MenuCtrl', ($scope, $rootScope, $q, Api, LocalStorage, SavedTarget) ->
    $rootScope.branchMode = false
    $scope.showSubmitBtn = true
    $scope.isPolling = false
    $scope.pollCount = 0
    $rootScope.acceptedLintPath = null
    $scope.pendingPaths = []

    testPath = (andAccept=false) ->
        deferred = $q.defer()
        path = $scope.targetPathInput
        Api.testPath(path, $rootScope.branchMode).then (response) ->
            $scope.pathExists = response.exists
            $scope.targets = response.targets

            if not _.isUndefined response.vcs
                $scope.vcs = response.vcs
                $scope.branch = response.branch
                $rootScope.vcsName = response.name

            if andAccept
                $scope.acceptPath()
            deferred.resolve()
        deferred.promise

    # Not using this currently
    updatePaths = ->
        if not $rootScope.acceptedLintPath
            return

        Api.testPath($rootScope.acceptedLintPath, $rootScope.branchMode).then (response) ->
            newPaths = _.without response.targets, $rootScope.activePaths()
            console.log 'newPaths:', newPaths, $scope.pendingPaths
            $scope.pendingPaths = newPaths
            if $scope.pendingPaths
                console.log '$scope.pendingPaths:', $scope.pendingPaths

    stopPolling = ->
        if $scope.pollInterval
            clearInterval($scope.pollInterval)
        $scope.isPolling = false

    showSaveBtn = ->
        $scope.showSaveBtn = true

    hideSaveBtn = ->
        $scope.showSaveBtn = false

    $scope.poll = ->
        stopPolling()

        $scope.pollInterval = setInterval ->
            paths = $rootScope.activePaths()
            if paths.length > 0
                Api.poll([$rootScope.acceptedLintPath], $rootScope.branchMode).then (response) ->
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
            $scope.poll()

    $scope.acceptPath = ->
        if !$scope.targets or $scope.targets.length == 0
            console.log 'here'
            return
        $scope.showSubmitBtn = false
        $scope.showSaveBtn = true
        $rootScope.acceptedLintPath = $scope.targetPathInput
        Api.fullScan($scope.targets).then (response) ->
            $rootScope.updateResults response
            $scope.poll()

    targetPathChange = ->
        stopPolling()
        $rootScope.branchMode = false
        path = $scope.targetPathInput
        if path
            $scope.showSubmitBtn = true
            testPath()
    $scope.targetPathChange = _.throttle(targetPathChange, 1000)

    $scope.toggleBranchMode = ->
        $rootScope.branchMode = !$rootScope.branchMode
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
        $rootScope.resetLintResults()
        save = LocalStorage.getSavedLintTarget path
        $rootScope.branchMode = save.branchMode
        $scope.targetPathInput = path
        $rootScope.acceptedLintPath = path
        testPath(true)
        $scope.showSaveBtn = false

    $scope.$watch 'loadedSavePath', ->
        loadSave $rootScope.loadedSavePath


    # Testing:
    # console.log 'LocalStorage.get():', LocalStorage.get()
    # devPath = '~/dev/ua/airship/airship/apps/messages'

    # saved = new SavedTarget({path: devPath, branchMode: true})
    # LocalStorage.saveLintTarget saved

    # $scope.saves = LocalStorage.savedLintTargets()

    # $scope.targetPathInput = devPath
    # $scope.toggleBranchMode()
