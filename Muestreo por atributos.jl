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
---
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
	
	---
	"""
end

# ╔═╡ c906f8a9-1752-443c-a157-223456258ce9
cm"""
Idealmente ``p`` y ``d/n`` deberían ser iguales, pero comprobamos que no siempre es así. Solamente ocurre cuanto el tamaño de muestra es muy elevado. El problema es que un tamaño de muestra muy elevado, los costes debidos al muestreo se hacen muy altos.

Es necesario que estudiemos el problema con más detalle para encontrar un valor de ``n`` que nos permita unos resultados con unas garantías aceptables pero que no disparen los costes.
"""

# ╔═╡ 48265e3f-071c-4813-ba18-a67ff1e3eb38
cm"""
## Creación del plan de muestreo

Como hemos visto un plan de muestreo consta de:

* ``n``, el tamaño de muestra, y,
* ``c``, el criterio de aceptación, que es el número máximo aceptable de unidades no conformes en la muestra.

El lote será aceptable si ``d \le c``.

Veamos un ejemplo de apliación del muestreo:

---
!!! note "Ejemplo de la apliación de un plan de muestreo"

Seleccionar las características del lote y del plan de muestreo. Al modificar cualquiera de los valores, se realiza la simulación. Para repetirla sin cambiar los valores, solo hay que pulsarl el botón "Repetir la simulación".
"""

# ╔═╡ 57fbc946-c6c9-4a89-87ab-067f6bbea4e6
# Ejemplo: apl
md"""
**Características del lote:**

_N_ = $(@bind N_apl Slider(100:1000, show_value=true, default=500)) | 
_p_ = $(@bind p_apl Slider(0.:.001:0.2, show_value=true, default=0.01))

**Muestra:**

_n_ = $(@bind n_apl Slider(0:1000, show_value=true, default=100)) | _c_ = $(@bind c_apl Slider(0:30, show_value=true, default=0))

$(@bind go_apl Button("Repetir al simulación"))
"""

# ╔═╡ 0295d3b5-0808-4442-969a-71b02ffbc777
begin
	go_apl
	
	plan_apl = Plan(n_apl, c_apl, false)
	md"""
	Se **$(simul_muestreo(plan_apl, Int(floor(p_apl*N_apl)), N_apl, 1) == 1 ? "acepta" : "rechaza")** el lote.
	
	---
	"""
end

# ╔═╡ 24bffeb8-8ddf-44ab-ae2b-09a7c9782bbd
md"""
Comprobamos hay situaciones en las que prácticamente siempre se acepta el lote. Esto se produce cuando:
1. El nivel de calidad es muy bueno, es decir, valores de fracción de unidades no conformes $p$ bajos, es decir, pocas unidades no conformes en el lote
2. Planes de muestreo poco exigentes, ya sea porque el tamaño de muestra $n$ bajos o por criterios de aceptación $c$ demasiado elevados.

También tenemos la situación contraria, en la que los lotes se rechazan prácticamente todas las veces. Viendo los casos en los que domina la aceptación, es sencillo entender cuando se da la situación contraria.

Existen situaciones intermedias en los que la aceptación y el rechazo se da en un número simular.

El resultado es que tenemos una incertidumbre cuando se realiza un muestreo. Es inevitable ya que estamos trabajando con información incompleta. Debemos estudiar mejor este problema para poder encontrar una solución satisfactoria.

---
!!! note "Ejemplo: Muchos muestreos"

En este caso, en lugar de realizar un solo muestreo vamos a realizar varios muestreos de un mismo lote y contaremos cuantas veces se acepta el lote.
"""

# ╔═╡ 9f95f89a-0f3d-445d-8991-f69961fca35f
# Ejemplo: simul
md"""
**Características del lote:**

_N_ = $(@bind N_simul Slider(100:1000, show_value=true, default=800)) | 
_p_ = $(@bind p_simul Slider(0.:.001:0.2, show_value=true, default=0.016))

**Muestra:**

_n_ = $(@bind n_simul Slider(0:1000, show_value=true, default=100)) | _c_ = $(@bind c_simul Slider(0:30, show_value=true, default=1))

Número de simulaciones: $(@bind num_simul Select([1, 10, 100, 1000, 10_000, 100_000], default=100)) | $(@bind go_simul Button("Repetir"))

**Resultado de la simulación:**
"""

# ╔═╡ 56b21ea7-d015-4f5b-91ed-b8db6bc1b271
begin
	go_simul
	
	
	plan_simul = Plan(n_simul, c_simul, false)
	acep_simul = Int(round(simul_muestreo(plan_simul, Int(floor(p_simul*N_simul)), N_simul, num_simul)*num_simul))
	md"""
	Se aceptan | Se rechazan | Total
	:---------:|:-----------:|:------:
	$acep_simul|$(num_simul-acep_simul) | $num_simul

	---
	"""
end

# ╔═╡ 5a43c763-d972-41e2-8f5a-161c15b3587b
cm"""
Podemos calcular la probabilidad de aceptar un lote ``P_a`` a partir de los datos anteriores:
	
```math
P_a = \frac{\text{Núm. de lotes aceptados}}{\text{Número total de lotes muestreados}}
```
$(aside(tip(md"``P_a``: Probabilidad de aceptar un lote con un nivel de calidad ``p``.")))

Para la simulación anterior, encontramos que:

``P_a`` = $(acep_simul)/$num_simul = $(round(acep_simul/num_simul;digits=3))
"""


# ╔═╡ df6efd4c-764a-4955-a74b-e482ec4ce79f
md"""
## Obtención de la curva característica de operación

La probabilidad de aceptación nos permite saber si un lote con un cierto nivel de calidad será más probable que sea rechazado o aceptado. Idealmente deseamos que los lotes con un nivel de calidad adecuado se acepten siempre y si el nivel de calidad del lote es peor que el objetivo de calidad, se rechacen.

Podemos representar de manera gráfica el razonamiento anterior representando $P_a$ en función de $p$. Esta gráfica se denomina **curva característica de operación**.
"""

# ╔═╡ cc70fc39-6884-485a-b1c5-c73445d05f39
md"""
Si el tamano de muestra coincide con el tamaño del lote no existe incertidumbre, ya que inspeccionamos todas las unidades del lote, se conoce el nivel de calidad sin margen de duda. Esta curva característica es la curva característica ideal.

$(aside(tip(md"Se puede comprobar esta afirmación fácilmente con la simulación anterior.")))
---
!!! note "Curva característica de operación ideal"
"""

# ╔═╡ 1e3e1c9f-cd6a-403c-b5fc-c64a4bd50e6b
# ejemplo: ideal
md"""
Nivel de calidad aceptable (NCA) = $(@bind p_ideal Slider(0:.1:1, show_value=true, default=0.5))
"""

# ╔═╡ e2761ee8-6430-4d67-9e88-6f344f39a509
begin
	lims_ideal = [0, 1, p_ideal]
	lims_text_ideal = [0, 1, "NCA"]
	plot(0:.001:1, x->(x <= p_ideal ? 1 : 0), ylabel="Pₐ", xlabel="p", legend=false,
	lw=4, fill=0, fillalpha=.2, xticks=(lims_ideal, lims_text_ideal))
	annotate!(p_ideal/2, 0.5, "Aceptación")
	annotate!(p_ideal+(1-p_ideal)/2, 0.5, "Rechazo")
end

# ╔═╡ 1417443b-5b5c-477d-ba65-e5a3dc4f6811
md"""
---
Podemos dibujar la curva característica de operación para un plan de muestreo utilizando las simulaciones que hemos planteado más arriba. Tendremos que repetir las simulaciones para todos los valores de _p_ que queramos representar.

---
!!! note "Curva característica de operación mediante simulaciones"
"""

# ╔═╡ bed5a7a3-1742-48b4-86a1-44e1b4216839
# ejemplo:OCsim
md"""
**Características del lote:**

_N_ = $(@bind N_OCsim Slider(100:1000, show_value=true, default=800)) | 
_p máx_ = $(@bind p_OCsim Slider(0.:.001:0.2, show_value=true, default=0.016))

**Muestra:**

_n_ = $(@bind n_OCsim Slider(0:1000, show_value=true, default=100)) | _c_ = $(@bind c_OCsim Slider(0:30, show_value=true, default=1))

Número de simulaciones: $(@bind num_OCsim Select([1, 10, 100, 1000, 10_000, 100_000], default=100)) | $(@bind go_OCsim Button("Repetir"))

**Resultado de la simulación:**
"""

# ╔═╡ 9da34e6b-b895-4e95-9dfd-506e0781e00a
begin
	go_OCsim
	
	plan_OCsim = Plan(n_OCsim, c_OCsim, false)
	np_OCsim = 0:Int(round(p_OCsim*N_OCsim))
	oc_OCsim = crear_oc(plan_OCsim, np_OCsim, N_OCsim, num_OCsim)
	scatter(oc_OCsim.p, oc_OCsim.Pa, legend=false, xlabel="p", ylabel="Pₐ")
end

# ╔═╡ d1a20e83-954a-4a7c-ba22-223d0ed3a0da
md"""
---
Hemos calculado la curva característica de operación "experimentalmente". El problema es que hemos necesitado $(num_OCsim*length(np_OCsim)) simulaciones para poder obtenerla.

Este método funciona, pero  tiene que haber una manera más sencilla de obtener los datos de probabilidad de aceptación sin tener que realizar tantos cálculos.
"""

# ╔═╡ f8ab6471-7a20-4360-a306-a1c9b236751b
md"""
## Curvas OC a partir de las funciones de distribución
"""

# ╔═╡ 5ad473e8-e5e2-4c0a-b4a3-3f98cfabeeef


# ╔═╡ 9da2825d-66ff-4768-b3b0-1c865f53ba06
md"""
---
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
# ╟─48265e3f-071c-4813-ba18-a67ff1e3eb38
# ╟─57fbc946-c6c9-4a89-87ab-067f6bbea4e6
# ╟─0295d3b5-0808-4442-969a-71b02ffbc777
# ╟─24bffeb8-8ddf-44ab-ae2b-09a7c9782bbd
# ╟─9f95f89a-0f3d-445d-8991-f69961fca35f
# ╟─56b21ea7-d015-4f5b-91ed-b8db6bc1b271
# ╟─5a43c763-d972-41e2-8f5a-161c15b3587b
# ╟─df6efd4c-764a-4955-a74b-e482ec4ce79f
# ╟─cc70fc39-6884-485a-b1c5-c73445d05f39
# ╟─1e3e1c9f-cd6a-403c-b5fc-c64a4bd50e6b
# ╟─e2761ee8-6430-4d67-9e88-6f344f39a509
# ╟─1417443b-5b5c-477d-ba65-e5a3dc4f6811
# ╟─bed5a7a3-1742-48b4-86a1-44e1b4216839
# ╟─9da34e6b-b895-4e95-9dfd-506e0781e00a
# ╟─d1a20e83-954a-4a7c-ba22-223d0ed3a0da
# ╟─f8ab6471-7a20-4360-a306-a1c9b236751b
# ╠═5ad473e8-e5e2-4c0a-b4a3-3f98cfabeeef
# ╟─9da2825d-66ff-4768-b3b0-1c865f53ba06
# ╠═e940f120-fbe8-481b-ba90-17d5af80fa07
# ╠═10a95832-912a-4b4e-b165-41efd7cd6e61
