library(shiny)
library(DT)
library(bslib)

recipes_config <- yaml::read_yaml("recipes.yml")
recipes <- recipes_config$recipes
if (is.null(recipes)) {
  recipes <- list()
}

recipe_cards <- lapply(recipes, function(recipe) {
  column(
    width = 6,
    card(
      card_header(recipe$name),
      card_body(
        tags$ul(
          lapply(recipe$ingredients, function(ingredient) {
            tags$li(ingredient)
          })
        )
      )
    )
  )
})

page_navbar(
  title = "DoughBot",
  theme = bs_theme(version = 5, bootswatch = "minty"),

  nav_panel(
    "Calculator",
    sidebarLayout(
      sidebarPanel(
        h4("Target Settings"),
        radioButtons(
          "size_mode",
          "Size Input Method",
          choices = c(
            "Diameter (inches)" = "diameter",
            "Weight per Ball" = "weight"
          ),
          selected = "diameter"
        ),
        numericInput(
          "num_balls",
          "Number of Dough Balls",
          value = 3,
          min = 1,
          step = 1
        ),
        conditionalPanel(
          condition = "input.size_mode === 'weight'",
          numericInput(
            "ball_weight",
            "Weight per Ball (g)",
            value = 250,
            min = 50,
            step = 5
          )
        ),
        conditionalPanel(
          condition = "input.size_mode === 'diameter'",
          numericInput(
            "pizza_diameter",
            "Pizza Diameter (inches)",
            value = 12,
            min = 6,
            step = 0.5
          ),
          numericInput(
            "g_per_sq_in",
            "Dough Weight per sq in (g)",
            value = 2.2,
            min = 0.5,
            step = 0.1
          )
        ),
        helpText("12 inch pizza at 2.2 g/sq in is about 250g dough"),
        hr(),
        h4("Baker's Percentages"),
        sliderInput(
          "hydration",
          "Hydration % (Water)",
          min = 55,
          max = 75,
          value = 65,
          post = "%"
        ),
        numericInput(
          "salt_pct",
          "Salt %",
          value = 2.0,
          min = 0,
          max = 10,
          step = 0.1
        ),
        numericInput(
          "yeast_pct",
          "Yeast %",
          value = 0.6,
          min = 0,
          max = 5,
          step = 0.1
        ),
        numericInput(
          "oil_pct",
          "Oil/Fat % (Optional)",
          value = 0,
          min = 0,
          max = 20,
          step = 0.5
        ),
        numericInput(
          "sugar_pct",
          "Sugar/Honey % (Optional)",
          value = 0,
          min = 0,
          max = 10,
          step = 0.5
        ),
        hr(),
        actionButton("reset", "Reset to Defaults", icon = icon("undo"))
      ),

      mainPanel(
        h3(textOutput("recipe_title")),
        hr(),
        DTOutput("recipe_table"),
        br(),
        wellPanel(
          h4("Dough Summary"),
          textOutput("total_dough_weight"),
          textOutput("hydration_summary")
        )
      )
    )
  ),

  nav_panel(
    "Recipes",
    if (length(recipe_cards) > 0) {
      do.call(fluidRow, recipe_cards)
    } else {
      p("No recipes available.")
    }
  ),

  nav_panel(
    "About",
    div(
      class = "p-3",
      h3("About DoughBot"),
      p("DoughBot helps you calculate pizza dough using baker's percentages."),
      p("Use the Calculator tab to set dough targets and hydration levels."),
      p("Use the Recipes tab for quick references while planning your bake.")
    )
  )
)
