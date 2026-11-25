Feature: Department Suite

  Background:
    * url base_url

  @fetch
  Scenario: Fetch departments and query a random one
    Given path 'departments'
    When method get
    Then status 200
    And assert response.length > 0

    * def randomIndex = Math.floor(Math.random() * response.length)
    * def randomDeptId = response[randomIndex].departmentId

    * eval store.put('randomName', response[randomIndex].departmentName)
    * eval store.put('randomAddress', response[randomIndex].departmentAddress)

    Given path 'departments', randomDeptId
    When method get
    Then status 200
    And match response.departmentId == randomDeptId

  @search
  Scenario: Search departments where address is like
    * def randomAddress = store.get('randomAddress')
    Given path 'departments'
    And param address = randomAddress
    When method get
    Then status 200
    And assert response.length > 0

  @search
  Scenario: Search departments where name is
    * def randomName = store.get('randomName')
    Given path 'departments'
    And param name = randomName
    When method get
    Then status 200
    And assert response.length > 0

  @update
  Scenario: Fetch departments and update one
    Given path 'departments'
    When method get
    Then status 200
    And assert response.length > 0

    * def randomIndex = Math.floor(Math.random() * response.length)
    * def randomDeptId = response[randomIndex].departmentId
    * def randomDepartmentName = faker.randomUuid()
    * eval store.put('randomDepartmentName', randomDepartmentName)

    Given path 'departments', randomDeptId
    And request { "departmentName": "#(randomDepartmentName)" }
    When method put
    Then status 200
    And match response.departmentName == randomDepartmentName

    * def updatedDepartmentId = response.departmentId

    Given path 'departments', updatedDepartmentId
    When method get
    Then status 200
    And match response.departmentName == randomDepartmentName

  @delete
  Scenario: Search for department by name and delete first
    * def randomDepartmentName = store.get('randomDepartmentName')
    Given path 'departments'
    And param name = randomDepartmentName
    When method get
    Then status 200
    And assert response.length > 0

    * def departmentId = response[0].departmentId

    Given path 'departments', departmentId
    And method delete
    Then status 204