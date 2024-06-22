# nvim-drupal-sh #

Mappings/Functions that allows you to quickly inject drupal core services into; services, blocks, controllers and forms.

## Default mappings ##

- \<leader\>is => Shows a list of available core services.
- \<leader\>ie => Allows you to check if a service exists by entering name.
- \<leader\>ip => Used to pick service under cursor, use after \<leader\>is.
- \<leader\>ii => Creates constructor if none exists, also create method when needed.

## Setup ##

Add plugin via your plugin manager with the following.

```
"everynameistaken1/nvim-drupal-sh"
```

No further setup should be neccessary.

***Note***

When using \<leader\>ii. Be aware that if you use lsp formatter before injecting dependencies, your constructors parentheses will be on the same line so you will get an error stating that. Make sure to use \<leader\>is and \<leader\>ip once before formatting to avoid issue.

This project is not completely done, this ReadMe may change over time.