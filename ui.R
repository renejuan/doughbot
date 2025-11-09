library(shiny)
library(DT)

fluidPage(
  theme = bslib::bs_theme(version = 4, bootswatch = "minty"),
  titlePanel("🍕 DoughBot"),

  sidebarLayout(
    sidebarPanel(
      h4("Target Settings"),
      numericInput(
        "num_balls",
        "Number of Dough Balls",
        value = 4,
        min = 1,
        step = 1
      ),
      numericInput(
        "ball_weight",
        "Weight per Ball (g)",
        value = 250,
        min = 50,
        step = 5
      ),
      helpText("Standard Neapolitan is ~250g"),
      hr(),
      h4("Baker's Percentages"),
      sliderInput(
        "hydration",
        "Hydration % (Water)",
        min = 50,
        max = 90,
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
)
