@ignore
Feature: Create random departments

  Background:
    * url base_url

  Scenario: Create random department
    Given path 'departments'
    And request
      """
      {
        "departmentName": "#(faker.randomDepartment())",
        "departmentAddress": "#(faker.randomStreetAddress())",
        "departmentCode": "#('EC-' + faker.randomUuid())"
      }
      """
    When method post
    Then status 200
