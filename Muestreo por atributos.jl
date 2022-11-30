### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ e940f120-fbe8-481b-ba90-17d5af80fa07
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate("/Users/javier/.julia/dev/AcceptanceSampling")
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using Plots, AcceptanceSampling, PlutoUI, Kroki, Combinatorics, Distributions, PlutoTeachingTools, CommonMark
end

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

# ╔═╡ cd5cf515-29c9-43e5-a08e-5a3334815c3c
cm"""
## Necesidad del muestreo de aceptación

El muestreo es necesario porque tenemos que tomar decisiones a partir de información incompleta. Nos encontramos con un lote con un tamaño _N_ y queremos ver si su nivel de calidad es aceptable, ya sea porque somos productores y deseamos saber si es adecuado para poderlo enviar al cliente o porque estamos comprando el lote y tenemos que asegurarnos que el nivel de calidad es el que hemos pactado con el proveedor.

$(aside(tip(md"``N``: Tamaño el lote")))



"""

# ╔═╡ d88d73c0-bcb3-4b2b-a7df-57ca598dff48
cm"""
El nivel de calidad será la fracción de unidades no conformes del lote, es decir, el tanto por uno (o porcentaje) de unidades defectuosas del lote. Por ejemplo, un lote con un nivel de calidad de un 2 % o de 0.02. Se calcula así:

```math
p = \frac{\text{Núm. de defectos del lote}}{N}
```

$(aside(tip(md"``p``: Fracción de unidades no conformes del lote")))

El problema radica en que no podemos conocer el número total de unidades disconformes del lote sin inspeccionar todas las unidades, lo que no siempre es posible por motivos económicos, de tiempo o porque el análisis es destructivo.
"""

# ╔═╡ 2779ed47-513e-4715-8d9e-754d3fee3df3
cm"""
Para poder comprobar si el lote es aceptable, será necesario aplicar un **plan de muestreo**. El plan de muestreo consistira en tomar una muestra de tamaño ``n``. Esta muestra debe ser:
* Representativa
* Aleatoria
* Libre de errores sistemáticos

$(aside(tip(md"``n``: Tamaño de muestra")))

Además se debe elegir un _criterio de aceptación_ para decidir si el lote es aceptable o no.

Al elegir un plan de muestreo hay que especificar el tamaño de muestra y el criterio de selección.
"""

# ╔═╡ 4d7f301d-bb49-4526-b76d-10c2b7ce7ee4
cm"""
El número de unidades defectuosas que encontramos en la muestra lo denominamos ``d``. Si el tamaño de muestra es suficientemente elevado, ``\frac{d}{n}`` debería alcanzar el valor de ``p``.

$(aside(tip(md"``d``: Número de unidades no conformes de la muestra.")))
"""

# ╔═╡ bd53f4d6-0852-4d29-98a9-2005e42d4692
# Ejemplo intro
md"""
!!! note "Ejemplo: ¿Dónde están las unidades no conformes?"
	
_N_ = $(@bind N_intro Slider(100:1:500, default=150, show_value=true)) | Núm. de unidades no conformes = $(@bind d_intro Slider(0:60, show_value=true))

_n_ = $(@bind n_intro Slider(100:1:500, default=150, show_value=true))

Mostrar $(@bind mostrar_intro Select(["lote", "muestra", "unidades defectuosas"]))
"""

# ╔═╡ 082e6af1-0db1-40c6-9447-d44daea34c61
begin
	function reemplaza(string, posiciones, emoticono)
		array = collect(string)
		for i in posiciones
			array[i] = emoticono
		end
		join(array)
	end
	
	lote_intro = crear_lote(d_intro, N_intro)
	muest_intro = hacer_muestreo(n_intro, lote_intro, false)
	base_intro = "🥫"^N_intro
	defect_intro = reemplaza(base_intro, lote_intro.nc_pos, '💩')
	muestras_intro = reemplaza(base_intro, muest_intro.muestra_pos, '🧪')
	p_intro = d_intro/N_intro

	if mostrar_intro == "lote"
		show_intro = base_intro
	elseif mostrar_intro == "muestra"
		show_intro = muestras_intro
	elseif mostrar_intro == "unidades defectuosas"
		show_intro = defect_intro
	else
		show_intro = "Error al mostrar el lote. Fallo en el 'Select'"
	end
	
	cm"""
	 $(show_intro)

	 ``p`` = $(round(p_intro; digits=3)) | ``d/n``= $(round(muest_intro.d/n_intro; digits=3))
	"""
end

# ╔═╡ c906f8a9-1752-443c-a157-223456258ce9
cm"""
Idealmente ``p`` y ``d/n`` deberían ser iguales, pero comprobamos que no siempre es así. Solamente ocurre cuanto el tamaño de muestra es muy elevado. El problema es que un tamaño de muestra muy elevado, los costes debidos al muestreo se hacen muy altos.

Es necesario que estudiemos el problema con más detalle para encontrar un valor de ``n`` que nos permita unos resultados con unas garantías aceptables pero que no disparen los costes.
"""

# ╔═╡ 9da2825d-66ff-4768-b3b0-1c865f53ba06
md"""
---
"""

# ╔═╡ 10a95832-912a-4b4e-b165-41efd7cd6e61
PlutoUI.TableOfContents()

# ╔═╡ Cell order:
# ╟─a5587c32-709e-11ed-3047-b79d7fc586b9
# ╟─cd5cf515-29c9-43e5-a08e-5a3334815c3c
# ╟─d88d73c0-bcb3-4b2b-a7df-57ca598dff48
# ╟─2779ed47-513e-4715-8d9e-754d3fee3df3
# ╟─4d7f301d-bb49-4526-b76d-10c2b7ce7ee4
# ╟─bd53f4d6-0852-4d29-98a9-2005e42d4692
# ╟─082e6af1-0db1-40c6-9447-d44daea34c61
# ╟─c906f8a9-1752-443c-a157-223456258ce9
# ╟─9da2825d-66ff-4768-b3b0-1c865f53ba06
# ╠═e940f120-fbe8-481b-ba90-17d5af80fa07
# ╠═10a95832-912a-4b4e-b165-41efd7cd6e61
