```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "SpectralIndices.jl"
  text: "Easy formulas"
  tagline: Indices used in remote sensing and environmental monitoring.
  image:
    src: /logo.png
    alt: SpectralIndices
  actions:
    - theme: brand
      text: Getting Started
      link: /getting_started
    - theme: alt
      text: View on Github
      link: https://github.com/awesome-spectral-indices/SpectralIndices.jl
    - theme: alt
      text: API Axioms
      link: /api/axioms
      
features:
  - title: Support
    details: Supports a broad range of predefined spectral indices.
  - title: Creation
    details: Custom index creation capabilities.
  - title: Flexibility
    details: Flexible input options for various data types. Efficient computation for large datasets.
---
```

```@example index
using SpectralIndices
NDVI
```

> [!TIP]
> See some more with:

```@example index
indices
```