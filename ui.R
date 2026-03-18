library(shiny)
library(DT)
library(bslib)

recipes_config <- yaml::read_yaml("recipes.yml")
recipes <- recipes_config$recipes
if (is.null(recipes)) {
  recipes <- list()
}

app_theme <- bs_theme(
  version = 5,
  bg = "#f4efe8",
  fg = "#1e1b18",
  primary = "#8d3d22",
  secondary = "#dbc9b6",
  success = "#4f6f52",
  info = "#d97706"
)

recipe_cards <- lapply(recipes, function(recipe) {
  column(
    width = 6,
    div(
      class = "recipe-card-wrap",
      card(
        class = "recipe-card shadow-sm",
        card_body(
          div(class = "recipe-kicker", "House Favorite"),
          h3(class = "recipe-name", recipe$name),
          p(
            class = "recipe-copy",
            "A straightforward ingredient list to keep your bake day organized."
          ),
          tags$ul(
            class = "recipe-list",
            lapply(recipe$ingredients, function(ingredient) {
              tags$li(ingredient)
            })
          )
        )
      )
    )
  )
})

page_navbar(
  title = div(
    class = "brand-lockup",
    span(class = "brand-mark", "DoughBot"),
    span(class = "brand-subtitle", "Pizza Dough Studio")
  ),
  theme = app_theme,
  fillable = TRUE,
  header = tags$head(
    tags$style(HTML("
      :root {
        --db-bg: #f4efe8;
        --db-surface: rgba(255, 251, 245, 0.92);
        --db-surface-strong: #fffaf4;
        --db-border: rgba(78, 51, 34, 0.12);
        --db-shadow: 0 18px 40px rgba(70, 45, 30, 0.12);
        --db-shadow-soft: 0 10px 24px rgba(70, 45, 30, 0.08);
        --db-text: #1e1b18;
        --db-muted: #67584c;
        --db-accent: #8d3d22;
        --db-accent-dark: #5f2917;
        --db-highlight: #f0dfc8;
        --db-success: #4f6f52;
      }

      body {
        background:
          radial-gradient(circle at top left, rgba(240, 223, 200, 0.9), transparent 28%),
          radial-gradient(circle at top right, rgba(178, 111, 59, 0.12), transparent 24%),
          linear-gradient(180deg, #f7f1ea 0%, var(--db-bg) 38%, #eee5d9 100%);
        color: var(--db-text);
        font-family: Georgia, 'Times New Roman', serif;
      }

      h1, h2, h3, h4, h5, h6,
      .navbar,
      .btn,
      .control-label,
      .form-label {
        font-family: 'Trebuchet MS', 'Segoe UI', Arial, sans-serif;
      }

      .navbar {
        background: rgba(29, 24, 20, 0.88) !important;
        backdrop-filter: blur(12px);
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0 12px 30px rgba(18, 15, 12, 0.22);
      }

      .navbar-brand,
      .navbar-nav .nav-link {
        color: rgba(255, 248, 241, 0.88) !important;
      }

      .navbar-nav .nav-link.active,
      .navbar-nav .nav-link:hover {
        color: #ffffff !important;
      }

      .brand-lockup {
        display: flex;
        flex-direction: column;
        line-height: 1;
      }

      .brand-mark {
        font-size: 1.2rem;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
      }

      .brand-subtitle {
        margin-top: 0.18rem;
        font-size: 0.72rem;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        color: rgba(255, 248, 241, 0.6);
      }

      .tab-content {
        padding-top: 1.5rem;
        padding-bottom: 2rem;
      }

      .nav-page {
        scroll-padding-top: 5rem;
      }

      .bslib-sidebar-layout {
        gap: 1.5rem;
      }

      .sidebar {
        background: linear-gradient(180deg, rgba(255, 250, 244, 0.96), rgba(250, 240, 229, 0.94));
        border: 1px solid var(--db-border);
        border-radius: 28px;
        box-shadow: var(--db-shadow-soft);
        padding: 1.25rem 1.25rem 1.5rem 1.25rem;
      }

      .sidebar h4 {
        margin-top: 1.15rem;
        margin-bottom: 0.75rem;
        font-size: 0.9rem;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: var(--db-accent);
      }

      .sidebar hr {
        margin: 1.2rem 0;
        opacity: 0.12;
      }

      .form-label,
      .control-label {
        font-weight: 600;
        color: var(--db-text);
      }

      .form-control,
      .selectize-input,
      .irs--shiny .irs-bar,
      .irs--shiny .irs-single {
        border-radius: 14px;
      }

      .irs--shiny .irs-bar {
        background: linear-gradient(90deg, var(--db-accent), #c86a3d);
        border-top: 1px solid transparent;
        border-bottom: 1px solid transparent;
      }

      .irs--shiny .irs-handle > i:first-child {
        background-color: var(--db-accent);
      }

      .btn {
        border-radius: 999px;
        font-weight: 600;
        letter-spacing: 0.02em;
      }

      .btn-default,
      .btn-secondary {
        background: linear-gradient(180deg, #3c332d, #1f1a17);
        color: #fffaf4;
        border: none;
        box-shadow: 0 10px 20px rgba(31, 26, 23, 0.22);
      }

      .calculator-shell,
      .recipes-shell,
      .about-shell {
        padding: 0 0.35rem 0.5rem 0.35rem;
      }

      .content-card,
      .stat-card,
      .about-card,
      .recipe-card {
        background: var(--db-surface);
        border: 1px solid var(--db-border);
        border-radius: 28px;
        box-shadow: var(--db-shadow-soft);
      }

      .content-card .card-body,
      .stat-card .card-body,
      .about-card .card-body,
      .recipe-card .card-body {
        padding: 1.5rem 1.6rem;
      }

      .card-title-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
        margin-bottom: 0.8rem;
      }

      .section-kicker {
        font-size: 0.76rem;
        font-weight: 700;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        color: var(--db-accent);
      }

      .recipe-title {
        margin: 0;
        font-size: clamp(1.35rem, 2vw, 1.9rem);
        line-height: 1.15;
      }

      .section-copy,
      .stat-copy,
      .about-copy,
      .recipe-copy {
        color: var(--db-muted);
      }

      .stats-grid {
        margin-top: 1rem;
      }

      .quick-stats {
        margin-top: 1rem;
      }

      .target-controls {
        margin-top: 1rem;
      }

      .stat-card {
        min-height: 100%;
      }

      .stat-label {
        display: block;
        margin-bottom: 0.6rem;
        font-size: 0.74rem;
        font-weight: 700;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        color: var(--db-accent);
      }

      .stat-value {
        margin: 0;
        font-size: 1.12rem;
        font-weight: 700;
        line-height: 1.45;
      }

      .stat-value--compact {
        font-size: 1.5rem;
        line-height: 1.1;
      }

      .dataTables_wrapper {
        margin-top: 1rem;
        overflow-x: auto;
      }

      table.dataTable {
        width: 100% !important;
        border-collapse: separate !important;
        border-spacing: 0 0.6rem !important;
        min-width: 420px;
      }

      table.dataTable tbody tr {
        background: var(--db-surface-strong);
        box-shadow: 0 8px 18px rgba(85, 60, 43, 0.05);
      }

      table.dataTable tbody td {
        border-top: 1px solid rgba(141, 61, 34, 0.08) !important;
        border-bottom: 1px solid rgba(141, 61, 34, 0.08) !important;
        padding: 0.95rem 1rem !important;
      }

      table.dataTable tbody td:first-child {
        border-left: 1px solid rgba(141, 61, 34, 0.08) !important;
        border-top-left-radius: 16px;
        border-bottom-left-radius: 16px;
        font-weight: 600;
      }

      table.dataTable tbody td:last-child {
        border-right: 1px solid rgba(141, 61, 34, 0.08) !important;
        border-top-right-radius: 16px;
        border-bottom-right-radius: 16px;
      }

      .recipes-intro,
      .about-hero {
        margin-bottom: 1.35rem;
        padding: 1.8rem 1.9rem;
        border-radius: 30px;
        background: linear-gradient(135deg, rgba(255, 250, 244, 0.92), rgba(240, 223, 200, 0.82));
        border: 1px solid var(--db-border);
        box-shadow: var(--db-shadow-soft);
      }

      .recipes-title,
      .about-title {
        margin-bottom: 0.55rem;
        font-size: clamp(1.8rem, 3vw, 2.7rem);
      }

      .recipe-card-wrap {
        margin-bottom: 1.1rem;
      }

      .recipe-kicker {
        margin-bottom: 0.5rem;
        font-size: 0.72rem;
        font-weight: 700;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        color: var(--db-success);
      }

      .recipe-name {
        margin-bottom: 0.55rem;
      }

      .recipe-list {
        margin: 0;
        padding-left: 1.1rem;
      }

      .recipe-list li + li {
        margin-top: 0.35rem;
      }

      .about-grid {
        margin-top: 0.2rem;
      }

      @media (max-width: 991.98px) {
        .tab-content {
          padding-top: 1rem;
        }

        .sidebar {
          border-radius: 24px;
          padding: 1rem 1rem 1.25rem 1rem;
        }

        .content-card .card-body,
        .stat-card .card-body,
        .about-card .card-body,
        .recipe-card .card-body {
          padding: 1.25rem;
        }

        .card-title-row {
          align-items: flex-start;
          flex-direction: column;
        }
      }

      @media (max-width: 767.98px) {
        .calculator-shell,
        .recipes-shell,
        .about-shell {
          padding: 0;
        }

        .content-card,
        .stat-card,
        .about-card,
        .recipe-card,
        .recipes-intro,
        .about-hero {
          border-radius: 22px;
        }

        .stat-value {
          font-size: 1rem;
        }

        .stat-value--compact {
          font-size: 1.3rem;
        }

        table.dataTable {
          min-width: 360px;
        }
      }
    "))
  ),

  nav_panel(
    "Calculator",
    layout_sidebar(
      sidebar = sidebar(
        title = div(
          class = "sidebar-title-block",
          div(class = "section-kicker", "Dial In Your Dough"),
          h3("Calculator Controls")
        ),
        open = list(desktop = "open", mobile = "closed"),
        width = 370,
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
      div(
        class = "calculator-shell",
        card(
          class = "content-card",
          card_body(
            div(
              class = "card-title-row",
              div(
                div(class = "section-kicker", "Calculated Recipe"),
                div(class = "recipe-title", textOutput("recipe_title"))
              )
            ),
            div(
              class = "target-controls",
              layout_columns(
                col_widths = c(4, 4, 4),
                radioButtons(
                  "size_mode",
                  "Size Input Method",
                  choices = c(
                    "Diameter" = "diameter",
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
                    step = 1
                  )
                ),
                conditionalPanel(
                  condition = "input.size_mode === 'diameter'",
                  numericInput(
                    "g_per_sq_in",
                    "Dough Weight per sq in (g)",
                    value = 2.2,
                    min = 1,
                    step = 1
                  )
                )
              )
            ),
            div(
              class = "quick-stats",
              layout_columns(
                col_widths = c(4, 4, 4),
                card(
                  class = "stat-card",
                  card_body(
                    span(class = "stat-label", "Total Dough"),
                    div(class = "stat-value stat-value--compact", textOutput("total_dough_weight"))
                  )
                ),
                card(
                  class = "stat-card",
                  card_body(
                    span(class = "stat-label", "Per Ball"),
                    div(class = "stat-value stat-value--compact", textOutput("per_ball_summary"))
                  )
                ),
                card(
                  class = "stat-card",
                  card_body(
                    span(class = "stat-label", "Formula"),
                    div(class = "stat-value stat-value--compact", textOutput("formula_summary"))
                  )
                )
              )
            ),
            DTOutput("recipe_table")
          )
        ),
        card(
          class = "content-card",
          card_body(
            div(
              class = "card-title-row formula-summary-header",
              div(
                div(class = "section-kicker", "Formula Snapshot"),
                h3("Mixing context")
              )
            ),
            div(
              class = "quick-stats",
              layout_columns(
                col_widths = c(6, 6),
                card(
                  class = "stat-card",
                  card_body(
                    span(class = "stat-label", "Hydration"),
                    div(class = "stat-value", textOutput("hydration_summary"))
                  )
                ),
                card(
                  class = "stat-card",
                  card_body(
                    span(class = "stat-label", "Flour Basis"),
                    div(class = "stat-value", textOutput("flour_summary"))
                  )
                )
              )
            )
          )
        )
      )
    )
  ),

  nav_panel(
    "Recipes",
    div(
      class = "recipes-shell",
      div(
        class = "recipes-intro",
        div(class = "section-kicker", "Reference Library"),
        h2(class = "recipes-title", "Starter combinations for planning your next bake"),
        p(
          class = "section-copy",
          "Use these as quick assembly references once your dough formula is set. The presentation is intentionally simple so you can scan ingredients at a glance."
        )
      ),
      if (length(recipe_cards) > 0) {
        do.call(fluidRow, recipe_cards)
      } else {
        card(
          class = "content-card",
          card_body(
            div(class = "section-kicker", "Recipes"),
            h3("No recipes available"),
            p(class = "section-copy", "Add entries to `recipes.yml` to populate this section.")
          )
        )
      }
    )
  ),

  nav_panel(
    "About",
    div(
      class = "about-shell",
      div(
        class = "about-hero",
        div(class = "section-kicker", "Why DoughBot"),
        h2(class = "about-title", "A cleaner workflow for dough math"),
        p(
          class = "section-copy",
          "This app is built to make baker's percentages approachable while still feeling like a serious kitchen tool."
        )
      ),
      div(
        class = "about-grid",
        layout_columns(
          col_widths = c(4, 4, 4),
          card(
            class = "about-card",
            card_body(
              div(class = "section-kicker", "Precision"),
              h3("Consistent formulas"),
              p(
                class = "about-copy",
                "Every ingredient scales from a single flour weight, so the recipe stays coherent as batch size changes."
              )
            )
          ),
          card(
            class = "about-card",
            card_body(
              div(class = "section-kicker", "Speed"),
              h3("Fast planning"),
              p(
                class = "about-copy",
                "Swap between diameter-based and dough-ball-based planning without reworking the rest of the formula."
              )
            )
          ),
          card(
            class = "about-card",
            card_body(
              div(class = "section-kicker", "Reference"),
              h3("Recipe support"),
              p(
                class = "about-copy",
                "Keep a small library of topping combinations nearby so dough planning and pizza assembly live in one place."
              )
            )
          )
        )
      )
    )
  )
)
