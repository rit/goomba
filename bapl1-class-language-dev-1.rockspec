package = "bapl1-class-language"
version = "dev-1"
source = {
   url = "git+https://github.com/classpert/bapl1-class-language.git"
}
description = {
   homepage = "https://github.com/classpert/bapl1-class-language",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      interpreter = "interpreter.lua",
      pt = "pt.lua"
   }
}
