### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ a5587c32-709e-11ed-3047-b79d7fc586b9
md"""
# Muestreo de aceptación por atributos

## Esquema

1. Necesidad del muestreo de aceptación
2. Creación de un plan de muestreo
3. Obtención de la curva característica de operación
   1. Función hipergeométrica
   2. Función Binomial
   3. Función de Poisson
   4. Relación entre las tres funciones de distribución
4. Riesgo de comprador y del productor
5. Selección de un plan de muestreo por atributos
6. Planes de muestreo doble
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═a5587c32-709e-11ed-3047-b79d7fc586b9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
