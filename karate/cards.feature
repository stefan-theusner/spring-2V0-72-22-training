Feature: Cards Features

  Background:
    * url base_url

  Scenario: Kinds have the fields the UI reads
    Given path 'cards/kinds'
    When method get
    Then status 200
    And assert response.length === 7
    And match each response == { id: '#number', name: '#string', hint: '#string', cardCount: '#number' }

  Scenario: Categories have the fields and section names the UI shows
    Given path 'cards/categories'
    When method get
    Then status 200
    And assert response.length === 8
    And match each response == { id: '#number', code: '#string', name: '#string', cardCount: '#number' }
    And match response[*].name == ['Container & Config', 'AOP', 'Data & Transactions', 'Spring Data JPA', 'Web & REST', 'Security', 'Testing', 'Spring Boot']

  Scenario: Fetch cards filtered by kind only, pagination metadata included
    Given path 'cards'
    And param kind_ids = 1
    When method get
    Then status 200
    And assert response.content.length === 24
    And assert response.page === 0
    And assert response.size === 24
    And assert response.totalElements === 105
    And assert response.totalPages === 5
    And assert response.last === false
    And match each response.content[*].kind.id == 1

  Scenario: Fetch cards filtered by category only, kinds left empty
    Given path 'cards'
    And param category_ids = 1
    When method get
    Then status 200
    And assert response.content.length === 24
    And assert response.totalElements === 36
    And assert response.last === false
    And match each response.content[*].category.id == 1

  Scenario: Fetch cards filtered by several categories
    Given path 'cards'
    And params { category_ids: [1, 8] }
    When method get
    Then status 200
    And assert response.content.length === 24
    And assert response.totalElements === 80
    And match each response.content[*].category.id == '#? _ == 1 || _ == 8'

  Scenario: Fetch cards filtered by kinds and category
    Given path 'cards'
    And params { kind_ids: [1, 2], category_ids: [8] }
    When method get
    Then status 200
    And assert response.content.length === 20
    And assert response.totalElements === 20
    And assert response.totalPages === 1
    And assert response.last === true
    And match each response.content[*].kind.id == '#? _ == 1 || _ == 2'
    And match each response.content[*].category.id == 8

  Scenario: Fetch cards with a filter that matches nothing returns an empty page
    Given path 'cards'
    And params { kind_ids: [2], category_ids: [1] }
    When method get
    Then status 200
    And match response.content == []
    And assert response.totalElements === 0
    And assert response.last === true

  Scenario: Pages are stable and ordered by name
    Given path 'cards'
    And params { page: 0, size: 10 }
    When method get
    Then status 200
    And assert response.content.length === 10
    And assert response.totalPages === 20
    And def firstPage = response
    Given path 'cards'
    And params { page: 1, size: 10 }
    When method get
    Then status 200
    And assert response.content.length === 10
    And assert response.content[0].name > firstPage.content[9].name

  Scenario: Fetch a single card by id
    Given path 'cards/1'
    When method get
    Then status 200
    And match response contains { id: 1, name: '@Configuration' }

  Scenario: Card name index is complete and lightweight
    Given path 'cards/names'
    When method get
    Then status 200
    And assert response.length === 197
    And match each response == { id: '#number', name: '#string' }

  Scenario: Fetch kinds with card counts
    Given path 'cards/kinds'
    When method get
    Then status 200
    And match response[*].cardCount == [105, 14, 21, 27, 7, 7, 16]

  Scenario: Fetch categories with card counts, no kind filter
    Given path 'cards/categories'
    When method get
    Then status 200
    And match response[*].cardCount == [36, 14, 17, 16, 25, 21, 24, 44]

  Scenario: Fetch categories with card counts filtered by kinds
    Given path 'cards/categories'
    And params { kind_ids: [1, 2] }
    When method get
    Then status 200
    And assert response.length === 8
    And match response[*].cardCount == [25, 9, 6, 10, 20, 9, 20, 20]

  Scenario: Fetch categories filtered by a kind keeps categories without cards
    Given path 'cards/categories'
    And param kind_ids = 2
    When method get
    Then status 200
    And assert response.length === 8
    And match response[0] contains { id: 1, code: 'core', cardCount: 0 }
