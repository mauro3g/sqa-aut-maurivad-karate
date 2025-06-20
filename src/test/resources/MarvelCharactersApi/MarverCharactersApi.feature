@T-API-maurivad-0001-evaluacion @Agente1 @MarverCharactersApi

Feature: Pruebas de la API de Marvel Characters

  Background:
    * configure ssl = true
    * def baseUrl = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * def rand = java.lang.Math.floor(100000 + Math.random() * 900000)
    * def nombre = 'Atom Eve ' + rand

@id:1 @ObtenerPersonajes @CA1 @ignore
Scenario: Obtener todos los personajes de Marvel
    Given url baseUrl
    When method get
    Then status 200
    * def expected = read('classpath:MarvelCharactersApi/resources/getListResponse.json')
    * def actual = response
    * def isPresent = function(e){ karate.filter(actual, function(a){ return a.name == e.name && a.alterego == e.alterego }).length > 0 }
    * for(var i = 0; i < expected.length; i++) karate.match(isPresent(expected[i]), true)

@id:2 @ObtenerPersonajeIndividual @CA2
Scenario Outline: Obtener un personaje de Marvel por id y validar sus datos
    Given url baseUrl + '/' + id
    When method get
    Then status 200
    * match response.name == name
    * match response.alterego == alterego
    
    Examples: 
    | read('classpath:MarvelCharactersApi/resources/characters.csv') |

@id:3 @CrearPersonajeCamposVacios @CA3
Scenario: Validar error al crear personaje con campos vacíos
    Given url baseUrl
    And request { name: '', alterego: '', description: '', powers: [] }
    When method post
    Then status 400
    * def expected = { name: 'Name is required', description: 'Description is required', powers: 'Powers are required', alterego: 'Alterego is required' }
    * match response == expected

@id:4 @CrearPersonajeExitoso @CA4
Scenario: Crear un personaje de Marvel exitosamente
    Given url baseUrl
    And request { name: '#(nombre)', alterego: 'Eva', description: 'Inmortal', powers: ['Armor', 'Flight'] }
    When method post
    Then status 201
    * match response.name == nombre
    * match response.alterego == 'Eva'
    * match response.description == 'Inmortal'
    * match response.powers contains ['Armor', 'Flight']
    * karate.write(response.id, 'created-id.txt')
    

@id:5 @CrearPersonajeDuplicado @CA5
Scenario: Intentar crear un personaje con el mismo nombre y validar error
    Given url baseUrl
    And request { name: 'Iron Man', alterego: 'Eva', description: 'Inmortal', powers: ['Armor', 'Flight'] }
    When method post
    Then status 400
    * match response == { error: 'Character name already exists' }

@id:6 @CRUDPersonajeDinamico @CA6
Scenario: Crear, actualizar y borrar un personaje de Marvel de forma encadenada
    # Crear personaje
    * def nombre = 'Atom Eve ' + rand
    Given url baseUrl
    And request { name: '#(nombre)', alterego: 'Eva', description: 'Inmortal', powers: ['Armor', 'Flight'] }
    When method post
    Then status 201
    * def personajeId = response.id
    * match response.name == nombre
    * match response.alterego == 'Eva'
    * match response.description == 'Inmortal'
    * match response.powers contains ['Armor', 'Flight']

    #Visualizar personaje
    Given url baseUrl + '/' + personajeId
    When method get
    Then status 200
    * match response.name == '#(nombre)'
    * match response.alterego == 'Eva'

    # Actualizar personaje
    Given url baseUrl + '/' + personajeId
    * def bodyRequest = { name: nombre + ' actualizado', alterego: 'Evelin', description: 'Crea materia', powers: ['Xray', 'Flight'] }
    And request bodyRequest
    When method put
    Then status 200
    * match response.name == bodyRequest.name
    * match response.alterego == bodyRequest.alterego
    * match response.description == bodyRequest.description
    * match response.powers contains bodyRequest.powers

    # Borrar personaje
    Given url baseUrl + '/' + personajeId
    When method delete
    Then status 204




