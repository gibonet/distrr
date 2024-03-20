
# Push to github and gitlab -----------
# git push -u gitlab master
# git push -u origin master

# devtools --------
library(devtools)

load_all()

document()

check_man()
check()

build()

install(upgrade = "never")


