angular.module(APP_NAME).controller 'SavesCtrl', ($scope, $rootScope, LocalStorage) ->
    update = ->
        $scope.saves = LocalStorage.savedLintBundles()
    update()

    LocalStorage.addListener ->
        update()
