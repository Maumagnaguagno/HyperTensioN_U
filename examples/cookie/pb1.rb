require_relative 'Cookie'

plan = Cookie.problem(
  # Start
  {
    'at' => [
      ['bob','home']
    ],
    'have' => []
  },
  # Tasks
  [
    ['get_cookie', 'bob', 'home', 'cookie_store']
  ],
  # Debug
  ARGV.first == '-d'
)