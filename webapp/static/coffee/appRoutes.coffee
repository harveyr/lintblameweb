angular.module('myLilApp').config ['$routeProvider', ($routeProvider) ->
    $routeProvider
        .when('/', {
            controller: 'HomeCtrl'
            templateUrl: 'static/partials/home.html',
        })
        .otherwise({
            redirectTo: '/'    
        })
]
