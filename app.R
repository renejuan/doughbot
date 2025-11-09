library(shiny)
library(DT)

# --- UI ---
ui <- fluidPage(
  theme = bslib::bs_theme(version = 4, bootswatch = "minty"),
  titlePanel("🍕 DoughBot"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Target Settings"),
      numericInput("num_balls", "Number of Dough Balls", value = 4, min = 1, step = 1),
      numericInput("ball_weight", "Weight per Ball (g)", value = 250, min = 50, step = 5),
      helpText("Standard Neapolitan is ~250g"),
      hr(),
      h4("Baker's Percentages"),
      sliderInput("hydration", "Hydration % (Water)", min = 50, max = 90, value = 65, post = "%"),
      numericInput("salt_pct", "Salt %", value = 2.0, min = 0, max = 10, step = 0.1),
      numericInput("yeast_pct", "Yeast %", value = 0.6, min = 0, max = 5, step = 0.1),
      numericInput("oil_pct", "Oil/Fat % (Optional)", value = 0, min = 0, max = 20, step = 0.5),
      numericInput("sugar_pct", "Sugar/Honey % (Optional)", value = 0, min = 0, max = 10, step = 0.5),
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

# --- SERVER ---
server <- function(input, output, session) {
  
  # Reactive for total target weight
  total_target_weight <- reactive({
    req(input$num_balls, input$ball_weight)
    input$num_balls * input$ball_weight
  })
  
  # Reactive for Baker's Math total percentage
  total_bakers_pct <- reactive({
    100 + input$hydration + input$salt_pct + input$yeast_pct + input$oil_pct + input$sugar_pct
  })
  
  # Calculate the recipe
  recipe_data <- reactive({
    total_weight <- total_target_weight()
    total_pct <- total_bakers_pct()
    
    # The core baker's math formula: Flour = Total Weight / (Total Baker's % / 100)
    flour_g <- total_weight / (total_pct / 100)
    
    # Calculate other ingredients based on the flour weight
    water_g <- flour_g * (input$hydration / 100)
    salt_g <- flour_g * (input$salt_pct / 100)
    yeast_g <- flour_g * (input$yeast_pct / 100)
    oil_g <- flour_g * (input$oil_pct / 100)
    sugar_g <- flour_g * (input$sugar_pct / 100)
    
    # Create data frame
    df <- data.frame(
      Ingredient = c("Flour (100%)", "Water", "Salt", "Yeast", "Oil/Fat", "Sugar/Honey"),
      Grams = c(flour_g, water_g, salt_g, yeast_g, oil_g, sugar_g),
      Bakers_Percent = c(100, input$hydration, input$salt_pct, input$yeast_pct, input$oil_pct, input$sugar_pct)
    )
    
    # Filter out zero-amount optional ingredients for cleaner table
    df <- df[df$Grams > 0, ]
    
    df
  })
  
  # --- Outputs ---
  
  output$recipe_title <- renderText({
    paste("Recipe for", input$num_balls, "pizza(s) at", input$ball_weight, "g each")
  })
  
  output$recipe_table <- renderDT({
    dat <- recipe_data()
    
    datatable(dat, 
              options = list(dom = 't', pageLength = 10), # Simple table, no search/pagination needed
              rownames = FALSE,
              colnames = c("Ingredient", "Weight (g)", "Baker's %")
    ) %>%
      formatRound(columns = c("Grams"), digits = 1) %>%
      formatString(columns = c("Bakers_Percent"), suffix = "%")
  })
  
  output$total_dough_weight <- renderText({
    paste("Total Dough Weight:", format(round(total_target_weight(), 1), big.mark=","), "g")
  })
  
  output$hydration_summary <- renderText({
    paste("Hydration Level:", input$hydration, "% (", 
          ifelse(input$hydration < 60, "Stiff dough, good for standard ovens",
                 ifelse(input$hydration > 70, "Wet dough, requires high heat/skill", 
                        "Standard workable dough")),
          ")")
  })
  
  # Reset button observer
  observeEvent(input$reset, {
    updateNumericInput(session, "num_balls", value = 4)
    updateNumericInput(session, "ball_weight", value = 250)
    updateSliderInput(session, "hydration", value = 65)
    updateNumericInput(session, "salt_pct", value = 2.0)
    updateNumericInput(session, "yeast_pct", value = 0.6)
    updateNumericInput(session, "oil_pct", value = 0)
    updateNumericInput(session, "sugar_pct", value = 0)
  })
}

# Run the app
shinyApp(ui = ui, server = server)