angular.module(APP_NAME).controller 'SavesCtrl', ($scope, $rootScope, LocalStorage) ->
    update = ->
        $scope.saves = LocalStorage.savedLintTargets()

    update()
    LocalStorage.addListener ->
        update()
