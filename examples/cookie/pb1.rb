require_relative 'Cookie'

AT = 0
HAVE = 1

plan = Cookie.problem(
  # Start
  [
    [['bob','home']],
    []
  ],
  # Tasks
  [
    ['get_cookie', 'bob', 'home', 'cookie_store']
  ],
  # Debug
  ARGV.first == 'debug'
)

abort('Problem failed to generate expected plan') if plan != [
  [0.8, 8,
    ['goto', 'bob', 'home', 'cookie_store'],
    ['buy_good_cookie', 'bob']
  ],
  [0.2, -2,
    ['goto', 'bob', 'home', 'cookie_store'],
    ['buy_bad_cookie', 'bob']
  ]
]