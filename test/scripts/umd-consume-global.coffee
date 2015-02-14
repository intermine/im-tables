QUERY =
  name: 'Dashboard Query'
  select: [
    'company.name',
    'name',
    'employees.name',
    'employees.age'
  ]
  from: 'Department'
  where: [[ 'employees.age', '>', 35 ]]

SERVICE =
  root: "http://#{ window.location.hostname }:8080/intermine-demo/service"
  token: "test-user-token"

PAGE = start: 30, size: 15

imtables.configure
  TableCell:
    PreviewTrigger: 'hover'
    IndicateOffHostLinks: false

imtables.loadDash '#demo', PAGE, service: SERVICE, query: QUERY
        .then null, (e) -> console.error 'Error loading dash', e
