### A Pluto.jl notebook ###
# v0.19.18

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

# ╔═╡ c4bf4051-6214-45e2-824f-08ddffcd46a8
using Plots, PlutoUI, Kroki, Combinatorics, Distributions, PlutoTeachingTools, CommonMark

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

# ╔═╡ 5a43c763-d972-41e2-8f5a-161c15b3587b
cm"""
Podemos calcular la probabilidad de aceptar un lote ``P_a`` a partir de los datos anteriores:
	
```math
P_a = \frac{\text{Núm. de lotes aceptados}}{\text{Número total de lotes muestreados}}
```
$(aside(tip(md"``P_a``: Probabilidad de aceptar un lote con un nivel de calidad ``p``.")))

Para la simulación anterior, encontramos que:
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

# ╔═╡ f8ab6471-7a20-4360-a306-a1c9b236751b
md"""
## Curvas OC a partir de las funciones de distribución

Para entender como podemos calcular la probabilidad de aceptación sin necesidad de tener que recurrir a simulaciones, vamos a plantear un caso sencillo.
"""

# ╔═╡ aa7ae2c7-146a-4271-8988-e084370000b8
md"""
**Características del lote:**

_N_ = $(@bind N_senc Slider(1:20, show_value=true, default=10)) | 
_Np_ = $(@bind Np_senc Slider(0:20, show_value=true, default=3))

**Muestra:**

_n_ = $(@bind n_senc Slider(1:20, show_value=true, default=5)) | _c_ = $(@bind c_senc Slider(0:20, show_value=true, default=2))

Crearemos un lote con las características anteriores y marcaremos con una `💩` las unidades defectuosas:
"""

# ╔═╡ 5ad473e8-e5e2-4c0a-b4a3-3f98cfabeeef
# ejemplo: senc
md"""
!!! note "Caso sencillo de muestreo"

Consideremos el siguiente caso, tenemos un lote de $(N_senc) unidades. Tomaremos un tamaño de muestra de $(n_senc) unidades. El lote tendrá $(Np_senc) unidades defectuosas (_Np_) y se aceptarán lotes de $(c_senc) unidades.
"""

# ╔═╡ ac46a258-510a-4aff-889a-898c1ec763b9
begin
	lote_senc = [(i>Np_senc ? string(i)*"🥫" : string(i)*"💩") for i in 1:N_senc]
	combis_senc = collect(combinations(lote_senc, n_senc))
		
	function header(num)
		header_senc = "| "
		sep_senc = "|"
		for i in 1:num
			header_senc = header_senc*" "*" |"
			sep_senc = sep_senc*"---"*"|"
		end
		header_senc*"\n"*sep_senc*"\n"
	end
		
	function fila(fila_lote)
		fila_senc = "| "
		for i in fila_lote
			fila_senc = fila_senc*" "*i*" |"
		end
		fila_senc
	end
		
	function tabla(lote)
		texto_tabla=""
		for i in lote
			texto_tabla = texto_tabla*fila(i)*"\n"
		end
		texto_tabla = header(length(lote[1]))*texto_tabla
	end

	Markdown.parse(header(length(lote_senc))*fila(lote_senc))
end

# ╔═╡ 81136cc2-3b82-42d6-b3cb-5a31d5386720
md"""
Estas son todas las posibles muestras:

!!! warning
	Decidir que formato es mejor.
"""

# ╔═╡ 9b0eb510-3cf2-4f81-8acd-6ddf21e98501
collect(combinations(lote_senc, n_senc))

# ╔═╡ 443a220d-a0e0-4afb-b342-d0a22bccf2e6
# Markdown.parse(tabla(combis_senc))

# ╔═╡ 2be1caf2-e9ad-4a56-9f3e-213d9f2425f9
md"""
Tenemos un total de $(length(combis_senc)) posibles combinaciones. Estamos agrupando los $(N_senc) elementos del lotes en grupos de $(n_senc) unidades sin tener en cuenta el orden, es decir, estamos realizando las combinaciones:

$\textsf{Número total de combinaciones} = \binom{N}{n} = C_n^N = \frac{N!}{(N-n)! n!}$

La fórmula para encontar el número de combinaciones es el binomio de Newton.

Comprobamos con los datos del ejemplo que llegamos al resultado correcto:
"""

# ╔═╡ ebf037f7-d686-4804-a94c-114a98614bf7
md"""
Recapitulando el cálculo que hemos realizado, encontramos que la fracción con un número de unidades defectuosas _d_ es:

$\LARGE{
P(x=d) = \frac{\color{red}\overset{\overset{\text{Defectuosas}}{\big\uparrow}}{\binom{Np}{d}} \color{blue}\overset{\overset{\text{Correctas}}{\big\uparrow}}{\binom{N-Np}{n-d}}}{\color{green}\underset{\underset{\text{Total muestras}}{\big\downarrow}}{\binom{N}{n}}}
}$

Esta función se corresponde con la **función de distribución hipergeométrica**.
"""

# ╔═╡ 592d889c-f27c-476b-b8f1-10b89af68dc6
begin
	
	function mens_senc(c_senc)
		mens_senc = "P(x=0)"
		for i in 1:c_senc
			mens_senc *= " + P(x=$i)"
		end
		mens_senc
	end
	
	md"""
	Para calcular la probabilidad de aceptación del lote debemos conocer la suma de fracciones con un número de defectos menor o igual al criterio de aceptación. En nuestro ejemplo, el criterio de aceptación es $c_senc, por lo que la probabilidad de aceptación será:
	"""
end

# ╔═╡ 5d8c27f4-2f9a-40fc-aa41-5ac2a31765a9
md"""
Lo que supone que la probabilidad de aceptación en este caso es:
"""

# ╔═╡ 54195548-44f8-454c-ab16-4a25bb22fd80
md"""
Para realizar este cálculo hemos utilizado la función de distribución hipergeométrica acumulada

$P_a = \sum_{i=0}^c P(x=i) = \sum_{i=0}^c \frac{\binom{Np}{i} \binom{N-Np}{n-i}}{\binom{N}{n}}$

Podemos comprobar que el resultado obtenido es correcto:
"""

# ╔═╡ 7586803e-341b-4dc4-b7ee-a758483ec94d
cdf(Hypergeometric(Np_senc, N_senc-Np_senc, n_senc), c_senc)

# ╔═╡ 4129796d-7b81-4496-996d-5a13b28510e9
md"""
### Función Hipergeométrica

La función de distribución hipergeométrica se utiliza para planes de muestreo sin sustitución, es decir, planes de muestreo en los que las unidades muestreadas no se sustituyen.

Para poder dibujar la curva característica de operación utilizando la función de distribución hipergeométrica es necesario conocer:
-  $N$, el tamaño del lote
-  $N \cdot p$, el número de unidades no conformes del lote (el nivel de calidad)
-  $n$, el tamaño de muestra
-  $c$, el criterio de aceptación

Como hemos visto más arriba, la función de distribución es:

$$P(x=d) = \frac{\binom{Np}{d} \binom{N-Np}{n-d}}{\binom{N}{n}}$$

Para representar la curva característica de operación necesitaremos conocer la función de distribución acumulada:

$P_a = \sum_{i=0}^c P(x=i) = \sum_{i=0}^c \frac{\binom{Np}{i} \binom{N-Np}{n-i}}{\binom{N}{n}}$

Afortunadamente cualquier programa de estadística proporciona estos datos.

---
!!! note "Comprobación de que la simulación coincide con la función hipergeométrica"
"""

# ╔═╡ 012741ee-63d7-447e-bfb3-4b758b83d803
# ejemplo:hiper
md"""
**Características del lote:**

_N_ = $(@bind N_hiper Slider(1:500, show_value=true, default=300)) | 
_Np_ = $(@bind Np_hiper Slider(0:100, show_value=true, default=70))

**Muestra:**

_n_ = $(@bind n_hiper Slider(1:100, show_value=true, default=50)) | _c_ = $(@bind c_hiper Slider(0:20, show_value=true, default=4))

Número de simulaciones: $(@bind num_hiper Select([1, 10, 100, 1000, 10_000, 100_000], default=100)) | $(@bind go_hiper Button("Repetir"))

**Resultado de la simulación:**
"""

# ╔═╡ c0b69ab2-59b6-458a-93af-15d45ef5b81b
md"""
Comprobamos que los resultados de la simuación y de la teoría coinciden, como era de esperar. Evidentemente si el número de simulaciones es bajo, hay una mayor discrepancia.

---
"""

# ╔═╡ b4b87242-a80c-4d4f-9358-ae742ab3b8ac
md"""
### Función de distribución binomial

Otra función de distribución que se puede utilizar en muestreo es la función de distribución binomial. En este caso, calcularemos la probabilidad de aceptación en función de la fracción de unidades no conformes $p$.

La principal ventaja de la función de distribución binomial es que no es necesario conocer el tamaño del lote, ya que se trabaja con los valores de $p$.

La función de distribución binomial se utiliza para muestreos con reemplazo. Es decir, cada vez que se muestrea una unidad del lote, se sustituye por otra unidad. Esto supone que el tamaño el lote tras el muestreo es $N$ y no $N-n$.

---
!!! note "Función de distribución binomial"
"""

# ╔═╡ 4141e9e2-65e8-4491-8358-a8550f8df88d
# ejemplo: binom
md"""
**Características del lote:**

_N_ = $(@bind N_binom Slider(1:500, show_value=true, default=300)) | 
_p_ = $(@bind p_binom Slider(0:.05:1, show_value=true, default=.2))

**Muestra:**

_n_ = $(@bind n_binom Slider(1:100, show_value=true, default=50)) | _c_ = $(@bind c_binom Slider(0:20, show_value=true, default=4))

Número de simulaciones: $(@bind num_binom Select([1, 10, 100, 1000, 10_000, 100_000], default=100)) | $(@bind go_binom Button("Repetir"))

**Resultado de la simulación:**
"""

# ╔═╡ ee04a53c-7d7c-47df-8f15-cf9bf1b160f4
md"""
---
"""

# ╔═╡ 44f85a60-6de2-47c7-9361-c2bad5ae1e7b
cm"""
### Relación entre la función hipergeométrica y la binomial

Al aumentar el tamaño el lote ``N``, la función de distribución hipergeométrica tiende a la binomial.

---
!!! note "Comparativa entre la función hipergeométrica y binomial"
"""

# ╔═╡ 4bbebe53-3be9-4b47-b944-b764812d8436
# ejemplo : hipbin
md"""
_N_: $(@bind N_hipbin Slider(1:300, show_value=true, default=100)) $br
_n_: $(@bind n_hipbin Slider(1:300, show_value=true, default=10)) | _c_: $(@bind c_hipbin Slider(0:20, show_value=true))
"""

# ╔═╡ a4169de8-075a-4fdb-9d6c-e73762b5e45b
md"""
### Función de distribución de Poisson

---
!!! note "Función de distribución de Poisson"
"""

# ╔═╡ fa4bdf5e-ff14-4b16-8a0e-26f43b46a6a4
# ejemplo: poisson
md"""
**Características del lote:**

_N_ = $(@bind N_poisson Slider(1:500, show_value=true, default=300)) | 
_p_ = $(@bind p_poisson Slider(0:.05:1, show_value=true, default=.2))

**Muestra:**

_n_ = $(@bind n_poisson Slider(1:100, show_value=true, default=50)) | _c_ = $(@bind c_poisson Slider(0:20, show_value=true, default=4))

Número de simulaciones: $(@bind num_poisson Select([1, 10, 100, 1000, 10_000, 100_000], default=100)) | $(@bind go_poisson Button("Repetir"))

**Resultado de la simulación:**
"""

# ╔═╡ 93baaa1e-adc5-49dc-a64a-da267cb786be
md"""
#### Relación entre entre las funciones de distribución Binomial y Poisson

A medida que el valor de _n_ se hace más grande se comprueba que la función de distribución binomial tiende a la función de distribución de Poisson.

!!! note "Comparativa entre binomial y Poisson"
"""

# ╔═╡ 4e9d891f-66ce-4c41-a117-2495eb7bfb87
# ejemplo: binpois
	md"""
	_n_: $(@bind n_binpoiss Slider(1:100, show_value=true)) | 	_c_: $(@bind c_binpoiss Slider(0:20, show_value=true))
	"""

# ╔═╡ d5c25232-1df6-4c77-ab76-df8dc8bac22b
md"""
### Relación entre las tres funciones de distribución
"""

# ╔═╡ 0123bf23-1aa8-4910-aafa-79771bd74342
Diagram(:mermaid, """
flowchart TD
  A[Hipergeométrica] --> |"n/N ≤ 0.1 ."| B[p-Binomial]
  B --> |"np < 5"| Poisson
  B --> |"np ≥ 5"| Normal
  A --> |n/N > 0.1 .|C{"¿p?"} 
  C --> |"p ≤ 0.1 ."| f-Binomial
  C --> | p > 0.1 .| Ninguna
""")

# ╔═╡ 2384a847-f81e-48ab-9b1c-1f825990dda4
md"""
### Selección de un plan de muestreo a partir de α y β

A partir del código del paquete de R `AcceptanceSampling`.
"""

# ╔═╡ bde2496c-9326-4b66-baa3-48e5027c832c
α_ej = 0.05

# ╔═╡ 897835a5-176b-4c45-8b8a-627e8970aa7f
p₁_ej = 0.01

# ╔═╡ a0e44b25-5b8a-43e6-8e84-115e684e4900
β_ej = 0.10

# ╔═╡ 4283889e-27dc-4d5f-b91c-52169133a549
p₂_ej = 0.06

# ╔═╡ 9da2825d-66ff-4768-b3b0-1c865f53ba06
md"""
---
---
"""

# ╔═╡ e940f120-fbe8-481b-ba90-17d5af80fa07
# begin
#    import Pkg
#    # activate the shared project environment
#    Pkg.activate("/Users/javier/.julia/dev/AcceptanceSampling")
#    # instantiate, i.e. make sure that all packages are downloaded
#    Pkg.instantiate()
#
#    using Plots, AcceptanceSampling, PlutoUI, Kroki, Combinatorics, Distributions, PlutoTeachingTools, CommonMark
#end

# ╔═╡ 36cbfb80-8979-4068-9d38-9f4c307a2227
begin
	parser = Parser()
	enable!(parser, MathRule())
end

# ╔═╡ 882916a5-f383-444b-b872-04a901d0e983
begin
	combina(N, n) = factorial(N)/(factorial(N-n)*factorial(n))
	
	total_muestras_senc = Int(combina(N_senc, n_senc))

	parser("""
	```math
	\\binom{$N_senc}{$n_senc} = $total_muestras_senc
	```
	""")
end

# ╔═╡ 1e3dc7f5-a198-4c1b-bec8-ed709f7a740f
md"""
Las muestras tienen $(n_senc) elementos. De las $(Int(total_muestras_senc)), ¿cuántas tendrán $(@bind d_senc Scrubbable(2)) unidad no conforme?

Las muestras tienen dos partes, una parte con las unidades defectuosas (_d_) y otra con unidades correctas (_n - d_). En este ejemplo:
"""

# ╔═╡ 7f8cc7e7-0ac0-44ac-a66a-7e1cd1675e1f
md"""
| Defectuosas | Correctas |
|:-----------:|:----------:|
| $("👎"^d_senc) | $("👍"^(n_senc-d_senc)) |
"""

# ╔═╡ d7241e98-2e67-4cdf-8ed5-a55490c23049
md"""
Podemos ver cuantas combinaciones posibles existen para la parte de unidades defectuosas. En nuestro lote tenemos $(Np_senc) unidades defectuosas, son estas:

 $(lote_senc[1:Np_senc])

Las vamos a combinar en grupos de tamaño _d_ = $(d_senc):
"""

# ╔═╡ bd3501d6-b09a-48be-b944-311703d41e15
Markdown.parse(tabla(collect(combinations(lote_senc[1:Np_senc], d_senc))))

# ╔═╡ 18d23064-b6af-47f5-8634-da46c9a96c37
md"""
Vemos que tenemos $(length(combinations(lote_senc[1:Np_senc], d_senc))) posibles combinaciones. El resultado es esperable, ya que las combinaciones de $Np_senc elementos tomados de $d_senc en $d_senc es:
"""

# ╔═╡ b5a4c5c1-eb4d-440e-ac6d-54b98b234988
md"""
Para la parte de unidades no defectuosas, ¿cuántas posibles combinaciones son posibles? Como hemos visto más arriba, en el lote tenemos estas unidades no conformes:

 $(lote_senc[Np_senc+1:N_senc])

Las vamos a combinar de $(n_senc-d_senc) en $(n_senc-d_senc), ya que de la muestra (_n_ = $n_senc) $(n_senc-d_senc) unidades no tienen defectos.

Tenemos las siguientes combinaciones:
"""

# ╔═╡ 6eb0d2d2-08ab-4547-b77d-e1fb7ec02389
collect(combinations(lote_senc[Np_senc+1: N_senc], n_senc-d_senc))

# ╔═╡ 9613a4bc-75b5-40ad-aaba-b1f047e31948
md"""
Lo que supone un total de $(length(combinations(lote_senc[Np_senc+1: N_senc], n_senc-d_senc))) combinaciones.

Entonces, ¿cuántos posibles lotes tendrán $d_senc unidades no conformes? Simplemente será el producto entre el número de combinaciones debidas a las unidades no conformes por el número de combinaciones debidas a las unidades sin defectos:

 $(length(combinations(lote_senc[1:Np_senc], d_senc))) x $(length(combinations(lote_senc[Np_senc+1: N_senc], n_senc-d_senc))) = $(length(combinations(lote_senc[1:Np_senc], d_senc))*length(combinations(lote_senc[Np_senc+1: N_senc], n_senc-d_senc))) posibles combinaciones.

Esto supone que la fracción de unidades será:
"""

# ╔═╡ ac5ac670-64f4-4114-8ab6-456dfa8c8d4a
begin
	P(i) = combina(Np_senc, i) * combina(N_senc-Np_senc, n_senc-i) / combina(N_senc, n_senc)
	
	for i in 0:c_senc
		println("P($i) = $(P(i))")
	end
end

# ╔═╡ 7f7ede26-d6b1-40bd-bf19-159a1429a3a4
Pₐ = sum([P(i) for i in 0:c_senc])

# ╔═╡ 744e8f44-d93f-427b-ba36-2c843b05112f
parser("""
```math
\\binom{$(Np_senc)}{$(d_senc)} = $(combina(Np_senc, d_senc))
```
""")

# ╔═╡ 55f28da0-ea8e-42d1-bb7a-86968a594063
parser("""
```math
P(x=$d_senc) = \\frac{$(length(combinations(lote_senc[1:Np_senc], d_senc))*length(combinations(lote_senc[Np_senc+1: N_senc], n_senc-d_senc)))}{$(total_muestras_senc)} = $(length(combinations(lote_senc[1:Np_senc], d_senc))*length(combinations(lote_senc[Np_senc+1:N_senc], n_senc-d_senc))/total_muestras_senc)
""")

# ╔═╡ 534cd884-9e51-442f-a5ba-80ae8fdf81fc
parser("""
```math
P_a(x=$c_senc) = $(mens_senc(c_senc))
```
Ya hemos calculado P(x=$d_senc), ahora deberemos calcular el resto:
""")

# ╔═╡ 10a95832-912a-4b4e-b165-41efd7cd6e61
PlutoUI.TableOfContents()

# ╔═╡ 0a9abf7a-75f9-4abb-a95d-44103eff083b
"""
Definición de la estructura Lote, que tendrá dos elementos:

nc_pos: posición de las unidades no conformes
N: tamaño del lote
"""
struct Lote
	nc_pos :: Array{Int}
	N :: Int
end

# ╔═╡ 1403ac73-436a-4071-8141-3e2e3ea36c9b
"""
La estructura **Plan** representa un plan de muestreo. Sus elementos son:

- _n_: Tamaño de muestra
- _c_: Criterio de aceptación
- _sust_: Sustitución (true/false)
"""
struct Plan
	n :: Int
	c :: Int
	sust :: Bool
	Plan(n, c , sust) = c > n ? error("c no puede ser mayor que n") : new(n, c , sust)
end

# ╔═╡ ad939334-d67e-4887-b675-d7571dc801d3
"""
La estructura **Muestreo** representa el resultdo de realizar un muestreo a un lote. Sus elementos son:

- _d_: Número de unidades no conformes de la muestra.
- *muestra_pos*: Posición de las unidades muestreadas.
"""
struct Muestreo
	d :: Int
	muestra_pos :: Array{Int}
end

# ╔═╡ a1682a55-6260-4dae-96b7-c954abbe03b8
"""
La estructura **OC** representará los datos de la curva característica de operación y tendrá estos elementos:

- _p_: Fracción de unidades no conformes de cada uno de los puntos
- _Pa_: Las probabiliades de aceptación para cada puntos
- _plan_: Datos del plan de muestreo
"""
struct OC
	p :: Array{Float64}
	Pa :: Array{Float64}
	plan :: Plan
end

# ╔═╡ e3505b6e-7cf3-4971-9e41-3fdc54fa4f9d
"""
crear_lote(nc, N)

* nc: Número de unidades no conformes que tendrá el lote
* N: Tamaño del lote

El resultado es un array con la posición de las unidades no conformes.

Ejemplo:

crear_lote(4, 300)

[82, 235, 300, 153]
"""
function crear_lote(nc, N)
	# Muestreo sin sustitución para evitar que pueda haber dos unidades
	# no conformes en la misma posición
	Lote(sample(1:N, nc, replace=false), N)
end

# ╔═╡ d864375f-81f2-4e88-8c01-78874b617688
"""
muestreo(n, lote, sustitucion)

La función muestreo realiza un muestreo de _n_ unidades y da el número de unidades no conformes de la muestra, _d_. El muestreo se puede realizar con o sin sustitución.

- _n_: Tamaño de la muestra
- lote: Lote obtenido con `crear_lote`
- sustitucion: true = con sustitución / false = sin sustitución
"""
function hacer_muestreo(n::Int, lote::Lote, sustitucion)
	d = 0
	muestra = sample(1:lote.N, n, replace=sustitucion)
	for i in muestra
		if i in lote.nc_pos
			d +=1
		end
	end
	Muestreo(d, muestra)
end

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

# ╔═╡ 28ae014c-c806-4778-a189-f15082560227
"""
show_muestreo(lote, res_muestreo)

Representación en modo texto del muestreo de un lote. Los resultados los muestras como:

o: Muestra | x: Defecto | ⧇: Defecto encontrado

Los parámetros de la función son:

- _lote_: Lote a muestrear.
- *res_muestreo*: Resultado de un muestreo
"""
function show_muestreo(lote, res_muestreo)
    x = floor(lote.N^.5)
    y = lote.N/x
    defect = 1
    mensaje = ""
    for pos_y in 1:y
        for pos_x in 1:x
            if defect in lote.nc_pos
                if defect in res_muestreo.muestra_pos
                    mensaje *= "⧇ "
                else
                    mensaje *= "x "
                end
            else
                if defect in res_muestreo.muestra_pos
                    mensaje *= "o "
                else
                    mensaje *= "· "
                end
            end
            defect += 1
        end
        mensaje *= "\n"
    end
    mensaje *= "\no: Muestra | x: Defecto | ⧇: Defecto encontrado \nd = $(res_muestreo.d)"
    print(mensaje)
end

# ╔═╡ 7a2644aa-05d0-45c8-aade-1d540375135f
"""
simul_muestreo(plan, nc, N, simuls)

Simula la acción de muestreo para determinar empíricamente la probabilidad de aceptación.

- plan: Plan de muestreo creado con `crear_plan`
- nc: Número de unidades no conformes que tiene la muestra
- N: Tamaño del lote
- simuls: Número de simulaciones a realizar
"""
function simul_muestreo(plan::Plan, nc, N, simuls)
	# Número de lotes aceptados
	acept = 0
	for i in 1:simuls
		if hacer_muestreo(plan.n, crear_lote(nc, N), plan.sust).d <= plan.c
			acept += 1 
		end
	end
	acept/simuls
end

# ╔═╡ 0295d3b5-0808-4442-969a-71b02ffbc777
begin
	go_apl
	
	plan_apl = Plan(n_apl, c_apl, false)
	md"""
	Se **$(simul_muestreo(plan_apl, Int(floor(p_apl*N_apl)), N_apl, 1) == 1 ? "acepta" : "rechaza")** el lote.
	
	---
	"""
end

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

# ╔═╡ 5a7603cc-bdd1-4933-9052-85a14849ea7b
parser("""
```math
P_a = \\frac{$(acep_simul)}{$num_simul} = $(round(acep_simul/num_simul;digits=3))
```
""")

# ╔═╡ 726674e1-3a75-427b-9f6d-5c3347ba02c2
"""
crear_oc(plan, d, N, simuls)

La función `crear_oc` permite calcular empíricamente la curva característica de operación a partir de los siguientes parámetros:

- _plan_: Detalla los datos del plan de muestreo utilizado (n, c, sust)
- _d_: Array con el número de unidades no conformes de cada uno de los puntos de la curva (eje x)
- _N_: Tamaño del lote
- _simuls_: Número de veces que se simulará cada uno de los puntos
"""
function crear_oc(plan::Plan, d, N, simuls)
	Pa = []
	for d_i in d
		push!(Pa, simul_muestreo(plan, d_i, N, simuls))
	end
	OC(d./N, Pa, plan)
end

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

# ╔═╡ 9152ae1d-bc6a-44bc-8013-71c8099c5cc5
# Receta para dibujar la curva característica de operación
@recipe function f(oc::OC)
    oc.p, oc.Pa
end

# ╔═╡ d8b4e96c-bc05-4118-8959-9a449bc715d7
"""
Pa_b(p, n, c)

Cálculo de la probabilidad de aceptación _Pa_ utilizando la función de distribución binomial.
Los parámetros de la función son:

- p: Fracción de unidades no conformes para la que se calcula la probabilidad de acceptación.
- n: Tamaño de la muestra.
- c: Criterio de aceptación.
"""
Pa_b(p, n, c) = cdf(Binomial(n, p), c)

# ╔═╡ d21d43f1-7073-4c00-b5da-c58d0a9385c6
"""
Pa_p(p, n, c)

Cálculo de la probabilidad de aceptación _Pa_ utilizando la función de distribución de Poisson.
Los parámetros de la función son:

- p: Fracción de unidades no conformes para la que se calcula la probabilidad de acceptación.
- n: Tamaño de la muestra.
- c: Criterio de aceptación.
"""
Pa_p(p, n, c) = cdf(Poisson(p*n), c)

# ╔═╡ a8fb0229-4530-4a5f-a67c-b18bd1a3dfb9
"""
Pa_h(d, n, c, N)

Cálculo de la probabilidad de aceptación _Pa_ utilizando la función de distribución hipergeométrica.
Los parámetros de la función son:

- d: Número de unidades no conformes para la que se calcula la probabilidad de acceptación.
- n: Tamaño de la muestra.
- N: Tamaño del lote.
- c: Criterio de aceptación.
"""
Pa_h(d, n, c, N) = cdf(Hypergeometric(d, N-d, n), c)

# ╔═╡ 22ab97d1-0d87-4029-aaa5-5c97be784b53
"""
oc_b(plan, p)

La función oc_b calcula los datos de la curva OC según una función de distribución binomial.

Utiliza los siguientes parámetros:

- plan: Datos del plan de muestreo
- p: Array con los valores de fracción de unidades no conformes de los puntos a calcular
"""
function oc_b(plan::Plan, p)
	Pa = [Pa_b(p_i, plan.n, plan.c) for p_i in p]
	OC(p, Pa, plan)
end

# ╔═╡ ba2efcaf-e240-471b-a3d7-59406fe7eebd
begin
	go_binom
	plan_binom = Plan(n_binom, c_binom, true)
	Np_binom = Int(round(p_binom*N_binom))
	Np_arr_binom = 1:Int(round(Np_binom/20)):Np_binom
	oc_sim_binom = crear_oc(plan_binom, Np_arr_binom, N_binom, num_binom)
	oc_binom = oc_b(plan_binom, Np_arr_binom./N_binom)
	scatter(oc_sim_binom.p, oc_sim_binom.Pa, label="Simulación", xlabel="p", ylabel="Pₐ")
	plot!(oc_binom.p, oc_binom.Pa, line=:steppost, label="Función binomial")
end

# ╔═╡ 25336106-94df-4606-9c41-fb3003142d73
"""
oc_p(plan, p)

La función oc_p calcula los datos de la curva OC según una función de distribución de Poisson.

Utiliza los siguientes parámetros:

- plan: Datos del plan de muestreo
- p: Array con los valores de fracción de unidades no conformes de los puntos a calcular
"""
function oc_p(plan::Plan, p)
	Pa = [Pa_p(p_i, plan.n, plan.c) for p_i in p]
	OC(p, Pa, plan)
end

# ╔═╡ 1d9ffec6-27c3-4276-9619-cdd599a5c37c
begin
	go_poisson
	plan_poisson = Plan(n_poisson, c_poisson, true)
	Np_poisson = Int(round(p_poisson*N_poisson))
	Np_arr_poisson = 1:Int(round(Np_poisson/20)):Np_poisson
	oc_sim_poisson = crear_oc(plan_poisson, Np_arr_poisson, N_poisson, num_poisson)
	oc_poisson = oc_p(plan_poisson, Np_arr_poisson./N_poisson)
	scatter(oc_sim_poisson.p, oc_sim_poisson.Pa, label="Simulación", xlabel="p", ylabel="Pₐ")
	plot!(oc_poisson.p, oc_poisson.Pa, line=:steppost, label="Función de Poisson")
end

# ╔═╡ dcf261ac-ba74-4bc4-b511-fa8cdaeaac4b
begin
	p_binpoiss = 0.0:.001:0.5
	plan_binpoiss = Plan(n_binpoiss, c_binpoiss, false)
	poiss_binpoiss = oc_p(plan_binpoiss, p_binpoiss)
	bin_binpoiss = oc_b(plan_binpoiss, p_binpoiss)
	plot(poiss_binpoiss.p, poiss_binpoiss.Pa, label="Poisson", xlabel="p", ylabel="Pₐ", ylim=(0,0))
	plot!(bin_binpoiss.p, bin_binpoiss.Pa, label="Binomial")
end

# ╔═╡ a9c9145f-046f-4b60-b323-d8b49d78da41
"""
oc_h(plan, d, N)

La función oc_h calcula los datos de la curva OC según una función de distribución hipergeométrica. Utiliza los siguientes parámetros:

- plan: Datos del plan de muestreo
- d: Array con los valores de unidades no conformes de los puntos a calcular
- N: Tamaño del lote
"""
function oc_h(plan::Plan, d, N)
	Pa = [Pa_h(d_i, plan.n, plan.c, N) for d_i in d]
	output = OC(d/N, Pa, plan)
	return output
end

# ╔═╡ 83657735-d219-42dd-889f-8164b23c552f
begin
	go_hiper
	plan_hiper = Plan(n_hiper, c_hiper, false)
	Np_arr_hiper = 1:Int(round(Np_hiper/20)):Np_hiper
	oc_sim_hiper = crear_oc(plan_hiper, Np_arr_hiper, N_hiper, num_hiper)
	oc_hiper = oc_h(plan_hiper, Np_arr_hiper, N_hiper)
	scatter(oc_sim_hiper.p, oc_sim_hiper.Pa, label="Simulación", xlabel="p", ylabel="Pₐ")
	plot!(oc_hiper.p, oc_hiper.Pa, line=:steppost, label="Función hipergeométrica")
end

# ╔═╡ 51fe4e59-9acf-4ea6-9ed4-4d9f9acb9edd
begin
	if n_hipbin <= N_hipbin && c_hipbin <= n_hipbin
		d_hipbin = 0:N_hipbin
		p_hipbin = d_hipbin./N_hipbin
		plan_hipbin = Plan(n_hipbin, c_hipbin, false)
		plan_reem_hipbin = Plan(n_hipbin, c_hipbin, true)
		hiper_hipbin = oc_h(plan_hipbin, d_hipbin, N_hipbin)
		bin_hipbin = oc_b(plan_reem_hipbin, p_hipbin)
		plot(hiper_hipbin.p, hiper_hipbin.Pa, label="Hipergeométrica",
			xlabel="p", ylabel="Pₐ", ylim=(0,0))
		plot!(bin_hipbin.p, bin_hipbin.Pa, label="Binomial")
	else
		error("n debe ser menor o igual que N y c debe ser menor o igual que n")
	end
end

# ╔═╡ 0eb0cd36-bc65-470f-87e3-aa2ddde8e143
"""
find_plan(p₁, α, p₂, β, dist)

Esta función selecciona `n` y `c` a partir del riesgo del productor (p₁, α) y del comprador (p₂, β).

El parámetro `dist` especifica la función de distribución utilizada:

- "b" para binomial
- "p" para Poisson
"""
function find_plan(p₁, α, p₂, β, dist)
	c = 0
	n = c+1
	if dist == "b"
		f = Pa_b
	elseif dist == "p"
		f = Pa_p
	end
	while true
		if f(p₂, n, c) > β
			n += 1
		elseif f(p₁, n, c) < 1- α
			c += 1
		else
			return n, c
		end
	end
end

# ╔═╡ 4717b6c3-6182-46f8-9216-7fa1cf6d0e56
find_plan(p₁_ej, α_ej, p₂_ej, β_ej, "b")

# ╔═╡ 177a4b51-f1ae-49e2-8c21-0a326554fd30
find_plan(p₁_ej, α_ej, p₂_ej, β_ej, "p")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Kroki = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Combinatorics = "~1.0.2"
CommonMark = "~0.8.7"
Distributions = "~0.25.79"
Kroki = "~0.2.0"
Plots = "~1.38.0"
PlutoTeachingTools = "~0.2.5"
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "18233cf79b9f05d4a7a5430d67158cc6b23a9e14"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "3bf60ba2fae10e10f70d53c070424e40a820dac2"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "a7756d098cbabec6b3ac44f369f74915e8cfd70a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.79"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "bcc737c4c3afc86f3bbc55eb1b9fabcee4ff2d81"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "64ef06fa8f814ff0d09ac31454f784c488e22b29"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.2+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "2e13c9956c82f5ae8cbdb8335327e63badb8c4ff"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.6.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "847da597e4271c88bb54b8c7dfbeac44ea85ace4"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.18"

[[deps.Kroki]]
deps = ["Base64", "CodecZlib", "DocStringExtensions", "HTTP", "JSON", "Markdown", "Reexport"]
git-tree-sha1 = "a3235f9ff60923658084df500cdbc0442ced3274"
uuid = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
version = "0.2.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "df6830e37943c7aaa10023471ca47fb3065cc3c4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "513084afca53c9af3491c94224997768b9af37e8"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "ea3e4ac2e49e3438815f8946fa7673b658e35bdb"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "18c35ed630d7229c5584b945641a73ca83fb5213"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "ab6083f09b3e617e34a956b43e9d51b824206932"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.1.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

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
# ╟─5a7603cc-bdd1-4933-9052-85a14849ea7b
# ╟─df6efd4c-764a-4955-a74b-e482ec4ce79f
# ╟─cc70fc39-6884-485a-b1c5-c73445d05f39
# ╟─1e3e1c9f-cd6a-403c-b5fc-c64a4bd50e6b
# ╟─e2761ee8-6430-4d67-9e88-6f344f39a509
# ╟─1417443b-5b5c-477d-ba65-e5a3dc4f6811
# ╟─bed5a7a3-1742-48b4-86a1-44e1b4216839
# ╟─9da34e6b-b895-4e95-9dfd-506e0781e00a
# ╟─d1a20e83-954a-4a7c-ba22-223d0ed3a0da
# ╟─f8ab6471-7a20-4360-a306-a1c9b236751b
# ╟─5ad473e8-e5e2-4c0a-b4a3-3f98cfabeeef
# ╟─aa7ae2c7-146a-4271-8988-e084370000b8
# ╟─ac46a258-510a-4aff-889a-898c1ec763b9
# ╟─81136cc2-3b82-42d6-b3cb-5a31d5386720
# ╟─9b0eb510-3cf2-4f81-8acd-6ddf21e98501
# ╠═443a220d-a0e0-4afb-b342-d0a22bccf2e6
# ╟─2be1caf2-e9ad-4a56-9f3e-213d9f2425f9
# ╟─882916a5-f383-444b-b872-04a901d0e983
# ╟─1e3dc7f5-a198-4c1b-bec8-ed709f7a740f
# ╟─7f8cc7e7-0ac0-44ac-a66a-7e1cd1675e1f
# ╟─d7241e98-2e67-4cdf-8ed5-a55490c23049
# ╟─bd3501d6-b09a-48be-b944-311703d41e15
# ╟─18d23064-b6af-47f5-8634-da46c9a96c37
# ╟─744e8f44-d93f-427b-ba36-2c843b05112f
# ╟─b5a4c5c1-eb4d-440e-ac6d-54b98b234988
# ╠═6eb0d2d2-08ab-4547-b77d-e1fb7ec02389
# ╟─9613a4bc-75b5-40ad-aaba-b1f047e31948
# ╟─55f28da0-ea8e-42d1-bb7a-86968a594063
# ╟─ebf037f7-d686-4804-a94c-114a98614bf7
# ╟─592d889c-f27c-476b-b8f1-10b89af68dc6
# ╟─534cd884-9e51-442f-a5ba-80ae8fdf81fc
# ╟─ac5ac670-64f4-4114-8ab6-456dfa8c8d4a
# ╟─5d8c27f4-2f9a-40fc-aa41-5ac2a31765a9
# ╠═7f7ede26-d6b1-40bd-bf19-159a1429a3a4
# ╟─54195548-44f8-454c-ab16-4a25bb22fd80
# ╠═7586803e-341b-4dc4-b7ee-a758483ec94d
# ╟─4129796d-7b81-4496-996d-5a13b28510e9
# ╟─012741ee-63d7-447e-bfb3-4b758b83d803
# ╟─83657735-d219-42dd-889f-8164b23c552f
# ╟─c0b69ab2-59b6-458a-93af-15d45ef5b81b
# ╟─b4b87242-a80c-4d4f-9358-ae742ab3b8ac
# ╟─4141e9e2-65e8-4491-8358-a8550f8df88d
# ╟─ba2efcaf-e240-471b-a3d7-59406fe7eebd
# ╟─ee04a53c-7d7c-47df-8f15-cf9bf1b160f4
# ╟─44f85a60-6de2-47c7-9361-c2bad5ae1e7b
# ╟─4bbebe53-3be9-4b47-b944-b764812d8436
# ╟─51fe4e59-9acf-4ea6-9ed4-4d9f9acb9edd
# ╟─a4169de8-075a-4fdb-9d6c-e73762b5e45b
# ╟─fa4bdf5e-ff14-4b16-8a0e-26f43b46a6a4
# ╟─1d9ffec6-27c3-4276-9619-cdd599a5c37c
# ╟─93baaa1e-adc5-49dc-a64a-da267cb786be
# ╟─4e9d891f-66ce-4c41-a117-2495eb7bfb87
# ╟─dcf261ac-ba74-4bc4-b511-fa8cdaeaac4b
# ╟─d5c25232-1df6-4c77-ab76-df8dc8bac22b
# ╟─0123bf23-1aa8-4910-aafa-79771bd74342
# ╟─2384a847-f81e-48ab-9b1c-1f825990dda4
# ╠═bde2496c-9326-4b66-baa3-48e5027c832c
# ╠═897835a5-176b-4c45-8b8a-627e8970aa7f
# ╠═a0e44b25-5b8a-43e6-8e84-115e684e4900
# ╠═4283889e-27dc-4d5f-b91c-52169133a549
# ╠═4717b6c3-6182-46f8-9216-7fa1cf6d0e56
# ╠═177a4b51-f1ae-49e2-8c21-0a326554fd30
# ╟─9da2825d-66ff-4768-b3b0-1c865f53ba06
# ╠═e940f120-fbe8-481b-ba90-17d5af80fa07
# ╠═c4bf4051-6214-45e2-824f-08ddffcd46a8
# ╠═36cbfb80-8979-4068-9d38-9f4c307a2227
# ╠═10a95832-912a-4b4e-b165-41efd7cd6e61
# ╠═0a9abf7a-75f9-4abb-a95d-44103eff083b
# ╠═1403ac73-436a-4071-8141-3e2e3ea36c9b
# ╠═ad939334-d67e-4887-b675-d7571dc801d3
# ╠═a1682a55-6260-4dae-96b7-c954abbe03b8
# ╠═e3505b6e-7cf3-4971-9e41-3fdc54fa4f9d
# ╠═d864375f-81f2-4e88-8c01-78874b617688
# ╠═28ae014c-c806-4778-a189-f15082560227
# ╠═7a2644aa-05d0-45c8-aade-1d540375135f
# ╠═726674e1-3a75-427b-9f6d-5c3347ba02c2
# ╠═9152ae1d-bc6a-44bc-8013-71c8099c5cc5
# ╠═d8b4e96c-bc05-4118-8959-9a449bc715d7
# ╠═d21d43f1-7073-4c00-b5da-c58d0a9385c6
# ╠═a8fb0229-4530-4a5f-a67c-b18bd1a3dfb9
# ╠═22ab97d1-0d87-4029-aaa5-5c97be784b53
# ╠═25336106-94df-4606-9c41-fb3003142d73
# ╠═a9c9145f-046f-4b60-b323-d8b49d78da41
# ╠═0eb0cd36-bc65-470f-87e3-aa2ddde8e143
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
