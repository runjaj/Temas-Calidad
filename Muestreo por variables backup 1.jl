### A Pluto.jl notebook ###
# v0.19.25

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

# ╔═╡ 7018db2a-60d1-11ed-2d8a-35c1275879bc
using Distributions, Random, Plots, PlutoUI, NLsolve, Kroki, CommonMark, Latexify

# ╔═╡ 9052c977-954c-4378-a5ef-1578120ca434
md"""
## Muestreo por variables

Consideremos que tenemos un parámetro de calidad que sigue una función de distribución normal y tiene estos parámetros:
"""

# ╔═╡ d4375a7c-40ca-4c18-a004-04b72c6c264e
μ = 8

# ╔═╡ 563743e6-5388-4465-ade9-c2ff3347e50f
σ = 2

# ╔═╡ e7a45ca1-1471-4d45-8ccf-84b71ca300de
md"""
Podemos crear una función que siga la función de distribución normal:
"""

# ╔═╡ 6ed24594-b711-4127-a114-5eceeb2aee45
pob_dist = Normal(μ, σ)

# ╔═╡ 8c23af09-ab77-40ea-b98c-f89a6433909b
num_muestras = 10000

# ╔═╡ 26da1373-0dda-474b-a680-4a4fbcf89424
md"""
Vamos a tomar $num_muestras al azar de esta función de distribución:
"""

# ╔═╡ c06be3c1-6bf1-4995-8da2-0239a4a30e8a
pob = rand(pob_dist, num_muestras)

# ╔═╡ 0c656691-5c9c-41d9-8b40-3a44c6243f1f
md"""
Podemos comprobar el ajuste de estos valores a una función de distribución normal:
"""

# ╔═╡ f56b1e9f-91ad-4eba-8ec9-82732e904d74
pob_dist_ej1 = fit(Normal, pob)

# ╔═╡ 8109a0fc-6ed9-43f7-8549-a1382218f12d
md"""
La representación del histograma con los valores y de la función ajustada:
"""

# ╔═╡ 3ce19bcd-2574-4db2-8091-27a2dc33974f
begin
	histogram(pob, normalize=true, legend=false)
	plot!((μ-3σ):.1:(μ+3σ), x->pdf(pob_dist_ej1,x), lw=4)
end

# ╔═╡ 787f1b94-ee8c-4a16-9da0-e917a14352cb
md"""
Aquí tenemos las muestras:
"""

# ╔═╡ 8027a81c-6d70-4376-9725-dc2ae8474acb
md"""
Para poder aplicar el plan de muestreo tendremos que encontar las medias de cada una de estas muestras:
"""

# ╔═╡ d006f3f5-6394-4e37-ba2b-fad9bceae446
md"""
De nuevo, podemos ajustar los valores a una función de distribución normal:
"""

# ╔═╡ 48d9c3bc-33de-4b66-85fd-c32ede2f8842
md"""
Al representar el gráifco podemos ver como afecta el tamaño de muestra a la desviación estándar.
"""

# ╔═╡ dccf9cf1-41c5-4e21-ab6f-d6c3b3044b98
md"""
n = $(@bind n_1 Slider(1:20, show_value=true))
"""

# ╔═╡ b0a13203-f9bf-44cb-b5b7-1396d889715b
md"""
### Influencia del tamaño de muestra

Vamos a tomar el mísmo número de valores aleatorios de la función de distribución que en el caso anterior pero agrupados en muestra de un tamaño _n_ = $n_1.

!!! note "Nota"

	El valor de _n_ se puede ajustar con el deslizador que junto al próximo gráfico.
"""

# ╔═╡ 12c01d45-86c7-4781-8547-0d1c6c092c15
muest = [rand(Normal(μ, σ), n_1) for i in 1:floor(num_muestras/n_1)]

# ╔═╡ 0b4fd00c-73a7-4bdb-9e86-50d9ffef05da
med_mues = mean.(muest)

# ╔═╡ 01060c3b-558d-4046-8ab2-25c813048c61
muest_dist = fit(Normal, med_mues)

# ╔═╡ a12bca4a-d8db-4306-9e8c-d5f1510acbc7
begin
	histogram(med_mues, normalize=true, fillalpha=0.25, fillcolor=:orange, label="")
	plot!((μ-3σ):.01:(μ+3σ), x->pdf(pob_dist_ej1,x), lw=4, label="U. individuales")
	plot!((μ-3σ):.01:(μ+3σ), x->pdf(muest_dist,x), lw=4, label="M. medias")
end

# ╔═╡ cfff154a-bc17-4d7e-bf48-f09a71dc184f
md"""
La desviación estándar de la muestra es:

$\sigma_m = \frac{\sigma}{\sqrt{n}}$
"""

# ╔═╡ da28f29d-4236-495d-a3eb-35073ae194d7
begin
	@latexdefine σₘ = σ/sqrt(n_1)
end

# ╔═╡ 7b1ceee8-1006-49b9-8dcd-cfecab969887
muest_dist.σ

# ╔═╡ 663a2370-c1de-4359-937d-f2e54f0aa8c1
md"""
### Límites de especificaciones

Vamos a considerar un límite inferior de especificaciones (_L_). Este es un valor que se puede fijar arbitrariamente, pero que en este caso lo vamos a hacer para un cierto valor de _p_:
"""

# ╔═╡ ddac22e6-2f5d-4c8f-8f63-738d836591f8
md"""
p = $(@bind p Slider(0.01:0.01:0.20, show_value=true, default=0.05))
"""

# ╔═╡ ff1657e8-0b38-4d4c-8f8a-1478bb7ff672
md"""
La posición de _L_ será considerando la distribución histórica del parámetro de calidad (población):
"""

# ╔═╡ bb18d41a-bcf6-4397-b11a-4c6586d53411
L = quantile(pob_dist, p)

# ╔═╡ c174a54e-19ed-4de4-b8a7-6837cd8a9118
md"""
Podemos ver la posición de _L_ en la curva:
"""

# ╔═╡ c805d759-6506-4b4e-8a89-930eb481d1c9
begin
	plot((μ-3σ):.01:(μ+3σ), x->pdf(pob_dist,x), lw=4, label="Un. individuales")
	plot!((μ-3σ):.01:L, x -> pdf(pob_dist,x), lw=0, fill=0, fillalpha=0.6, label="p = $p")
	plot!(L:.01:(μ+3σ), x -> pdf(pob_dist,x), lw=0, fill=0, fillalpha=0.3, label="Pₐ = $(round((1-p);digits=2))")
	plot!([L, L], [0, pdf(pob_dist, L)], lw=3, label="")
	annotate!(L, pdf(pob_dist, L), ("L", 14, :bottom))
end

# ╔═╡ 9361ef96-f92e-4608-a91a-57d9b6ff8fb5
md"""
Los límites de especificaciones, _L_ (inferior) y _U_ (superior), también se pueden fijar de manera arbitraria.
	
L = $(@bind L_arb Slider(2.5:.1:12.5, show_value=true))
"""

# ╔═╡ 054989a7-427e-45fe-a475-67ca8b065207
begin
	plot((μ-3σ):.01:(μ+3σ), x->pdf(pob_dist,x), lw=4, label="Un. individuales")
	plot!((μ-3σ):.01:L_arb, x -> pdf(pob_dist,x), lw=0, fill=0, fillalpha=0.6, label="p = $p")
	plot!(L_arb:.01:(μ+3σ), x -> pdf(pob_dist,x), lw=0, fill=0, fillalpha=0.3, label="Pₐ = $(round(1-cdf(pob_dist,L_arb); digits=3))")
	plot!([L_arb, L_arb], [0, pdf(pob_dist, L_arb)], lw=3, label="")
	annotate!(L_arb, pdf(pob_dist, L_arb), ("L", 14, :bottom))
end

# ╔═╡ 3362bced-65a0-49d9-b503-7111e7122297
md"""
Vamos a tomar el siguiente criterio de aceptación:

$$\frac{\bar{X}-L}{\sigma} \ge k$$

o lo que es lo mismo:

$$\bar{X} \ge k \sigma +L$$
"""

# ╔═╡ 63191c40-9860-470b-908a-bc167e34df3c
md"""
En la siguiente figura se muestra criterio de aceptación para diferentes valores de $\bar{X}$ y de $k$:
"""

# ╔═╡ bb399108-b88a-40bf-984e-35fcbf146480
md"""
 $k$ = $(@bind k_4 Slider(0:.1:1.5*σ, show_value=true, default = 1.0))

 $\bar{X}$ = $(@bind xbar_1 Slider(μ-2σ:.05:μ+3σ, show_value=true, default = μ))
"""

# ╔═╡ 2c982a39-d9a7-43f7-b3a7-ace5e7e630fa
begin
	# EJEMPLO 4
	p_pos = L
	ksigma = k_4*σ
	hk_4 = pdf(pob_dist, p_pos)/2
	miplot = plot((μ-3σ):.01:p_pos, x->pdf(pob_dist,x), lw=0, fill=0, fillalpha=.4, label="", fillcolor=:red, xlabel="p", ylabel="Pa")
	plot!((μ-3σ):.01:(μ+3σ), x->pdf(pob_dist,x), lw=4, label="U. individuales", color=:blue)
	vline!([p_pos, L+ksigma], label="")
	scatter!([xbar_1], [pdf(pob_dist, xbar_1)], markersize=8, label="")
	plot!([xbar_1, xbar_1], [0, pdf(pob_dist, xbar_1)], lw =2, label="")
	annotate!(xbar_1, pdf(pob_dist, L), (" x̄", :bottom, :left))
	vspan!([(μ-3σ), L+ksigma], fill=0.15, fillcolor=:red, label="Rechazo")
	vspan!([L+ksigma, μ+3σ], fill=0.15, fillcolor=:orange, label="Aceptación")
	plot!([p_pos, L+ksigma], [hk_4, hk_4], arrows=(:closed, :both), label="")
	annotate!(mean([p_pos, L+ksigma]), hk_4, ("kσ", :bottom))	
	annotate!(L, pdf(pob_dist, L), ("L", 14, :bottom))
end

# ╔═╡ c9580937-f448-4375-9c7f-902c7b84d5f6
cm"""
La muestra se **$(L+ksigma<=xbar_1 ? "ACEPTA" : "RECHAZA")**.
"""

# ╔═╡ 87028070-d3fa-4435-8205-c5f523a91695
md"""
### Curva característica de operación

Para poder determinar el tamaño de muestra y el criterio de aceptación, deberemos recurrir a la curva característica de operación.

Para poder dibujar esta curva característica, tenemos que poder calcular la probabilidad de aceptación de una muestra de tamaño _n_ con una fracción de unidades no conformes _p_ y un criterio de aceptación _k_.
"""

# ╔═╡ ba126afa-6f7b-43b3-b1b6-57c5e4a9e457
md"""
Podemos ver como como afecta el criterio de aceptación y el tamaño de muestra sobre la probailidad de aceptación para una determinada fracción de unidades no conformes:
"""

# ╔═╡ ba5f4420-1e38-4d58-94dd-7ea17cf2f81a
md"""
_p_ = $(@bind p_6 Slider(0.01:.005:.99, show_value=true))

_n_ = $(@bind n_6 Slider(1:30, show_value=true, default=10))

_k_ = $(@bind k_6 Slider(0.1:.1:2, show_value=true, default=1))
"""

# ╔═╡ 0c747e5a-4218-41a5-b5b8-57916db7bec7
md"""
Consideremos un caso en el que _n_ = $n_6 y _k_ = $k_6. Podemos dibujar la curva de distribución de las medidas individuales y de las medias de las muestras. Para las medidas individuales, _σ_ = $σ, y para la media de las muestras:

$$\sigma_{muestras} = \frac{\sigma}{\sqrt{n}}$$

lo que supone: $\sigma_{muestras}$ = $(round(σ/sqrt(n_6); digits=4)).
"""

# ╔═╡ 86db4e39-52a1-4cf0-8dfa-b9d5cef8f8ae
md"""
En verde se muestra la fracción aceptable, es decir, es la probabilidad de aceptación, _Pₐ_.
"""

# ╔═╡ 4c1fb69a-123b-4909-8015-208107c0e955
begin
	# EJEMPLO 6
	
	muest_dist_6 = Normal(μ, σ/sqrt(n_6))
	L_6 = quantile(pob_dist, p_6)
	plot((μ-3σ):.01:(μ+3σ), x->pdf(pob_dist,x), lw=4, label="U. individuales",
	xlabel="p", ylabel="Pa")
	plot!((μ-3σ):.01:(μ+3σ), x->pdf(muest_dist_6,x), lw=4, label="Med. muestras")
	plot!((μ-3σ):.01:L_6, x->pdf(pob_dist,x), lw=0, fill=0, fillcolor=:red, fillalpha=0.3, label="p = $p_6")
	vspan!([L_6, L_6+k_6*σ], fillalpha=0.5, fillcolor=:orange, fillstyle = :+, z_order=:back, label="kσ")
	plot!(L_6+k_6*σ:.01:μ+3σ, x->pdf(muest_dist_6,x), lw=0, fillcolor=:green, fill=0, fillalpha=0.3, label="Pₐ = $(round(ccdf(muest_dist_6, L_6+k_6*σ);digits=3))")
	plot!([L_6, L_6], [0, pdf(pob_dist, L_6)], lw=2, label="")
	plot!([L_6+k_6*σ, L_6+k_6*σ], [0, pdf(muest_dist_6, L_6+k_6*σ)], lw=2, label="")
end

# ╔═╡ 7b9bccb4-13da-4c04-acc2-311a947de6c2
md"""
Modificando los valores de $n$ y de $k$ podríamos encontrar los valores de probabilidad de aceptación y de fracción de unidades no conformes para los riesgos de productor y del comprador.
"""

# ╔═╡ 48ac993c-93fb-4f2e-83be-3f13dd00572e
md"""
Vamos a crear una función para calcular la probabilidad de aceptación que realiza el proceso que hemos visto en la figura anterior:
"""

# ╔═╡ f7fe9643-6c15-477e-b648-e48bfc36c2f5
function Pa(n, k, p)
	# Definimos la función de distribución de las muestras
	muest_dist = Normal(μ, σ/n^.5)
	# Cálculo del cuantil igual a p
	L = quantile(pob_dist, p)
	# Cálculo de la probabilidad de aceptación teniendo en cuenta el criterio de aceptación
	1-cdf(muest_dist, L+k*σ)
end

# ╔═╡ 7399ecb3-7271-4c60-b277-4513b9efdc12
md"""
A continuación se muestra una curva característica de operación con los siguientes parámetros del plan de muestreo:

_n_ = $(@bind n_7 Slider(1:30, show_value=true, default=10))

_k_ = $(@bind k_7 Slider(0.1:.1:2, show_value=true, default=1))
"""

# ╔═╡ 2f676820-3b6c-480c-8dc9-2464cb176d43
begin
	#EJEMPLO 7
	plot(0:.001:.5, p->Pa(n_7, k_7, p), lw=2, ylabel="Pₐ", xlabel="p", legend=false)
end

# ╔═╡ a0d6a372-1529-4c57-b2a5-8d51c5c048fa
md"""
Con la función para calcular la probabilidad de aceptación, ya podemos encontrar los valores de _n_ y_k_ que cumplen con los riesgos del comprador y del productor:

$$\begin{align}
P_a(n, k, p_1) &= 1- \alpha\\
P_a(n, k, p_2) &= \beta
\end{align}$$

Por ejemplo, consideremos que tenemos los siguientes riesgos y queremos encontrar el el tamaño de muestra _n_ y criterio de aceptación _k_ adecuados:
"""

# ╔═╡ 8bd2329b-0085-4852-b3ac-d05cb2995e71
p₁ = 0.01

# ╔═╡ c7852b2d-0dc9-4c8a-8f0a-9f14b16f5417
p₂ = 0.08

# ╔═╡ c93a6041-4686-46e3-bedc-a4a4c4b2274f
α = 0.05

# ╔═╡ 2b7f1b6b-5f60-43df-a531-f450542a27af
β = 0.10

# ╔═╡ 48b430ac-237e-4426-9b00-e2503e5397db
md"""
Resolveremos el sistema de ecuaciones numéricamente:
"""

# ╔═╡ 8e09ee89-21ef-4a71-95b6-6eb08d8e74ad
function f!(F, x)
	n = abs(x[1])
	k = abs(x[2])
	F[1] = Pa(n, k, p₁) - (1-α)
	F[2] = Pa(n, k, p₂) - β
end	

# ╔═╡ abbcb6ad-72d3-4fef-a41e-72e8c33506d3
sol = nlsolve(f!, [21., 2.], autodiff=:forward)

# ╔═╡ 3dcc22f0-ac38-4df6-b863-376d73b88d6a
abs.(sol.zero)

# ╔═╡ 424d7e13-0112-4db3-957c-8b066d19f21e
md"""
Obtenemos los siguientes resultados:

* _n_ = $(ceil(abs(sol.zero[1])))

* _k_ = $(round(sol.zero[2]; digits=4))
"""

# ╔═╡ 021e4511-28a8-4d9d-b889-6a70b9a0a831
md"""
A continuación se muestra la curva característica de operación del plan de muestreo encontrado, junto a los puntos de los riesgos:
"""

# ╔═╡ be08a856-8d4c-4dc5-9c60-09ecee98318d
begin
	plot(0:.001:.1, p->Pa(ceil(abs(sol.zero[1])), sol.zero[2],p), lw=2, ylabel="Pₐ", xlabel="p", legend=false)
	scatter!([p₁, p₂], [1-α, β])
	annotate!(p₁, 1-α, (" PRP", 10, :left, :bottom))
	annotate!(p₂, β, (" CRP", 10, :left, :bottom))
end

# ╔═╡ feb81ece-6503-4a46-b448-235f50434284
md"""
El problema es que calcular _k_ y _n_ de esta manera puede resultar complicado. Alternativamente, se pueden calcular los valores utilizando las siguientes fórmulas:

$$\begin{align}
k &= \frac{z_{p_2} z_\alpha+z_{p_1}z_\beta}{z_\alpha+z_\beta}\\
n &= \left\lceil \left(\frac{z_\alpha+z_\beta}{z_{p_1}-z_{p_2}} \right)^2 \right\rceil
\end{align}$$
"""

# ╔═╡ d7b270c1-8f3f-4ea1-99c0-95e20ae94474
md"""
!!! note "Nota"
	La función $z_x$ es la función cuantil:

	$$\Phi^{-1}(p) = \sqrt2 \;\operatorname{erf}^{-1} (2p - 1), \quad p\in(0,1)$$
"""

# ╔═╡ 04af219e-0f6c-4f0f-905f-fbecd1daed44
md"""
!!! note "Nota"
	El símbolo $\lceil\ \rceil$ indica que hay que tomar el número entero superior. Por ejemplo, $\lceil 12.3 \rceil = 12$.
"""

# ╔═╡ e3289b5d-4119-45d7-9582-19be179702e7
md"""
A continuación se muestran los valores de _n_ y _k_ obtenidos con las fórmulas anteriores y comprobamos que obtenemos los mismos resultdos:
"""

# ╔═╡ 0e2add63-2ad1-4ffa-93a8-f5889dc5fc89
z(x) = cquantile(Normal(),x)

# ╔═╡ 0348d00a-45f3-4b11-9a9b-23289d9026c6
k_calc = (z(p₂)*z(α)+z(p₁)*z(β))/(z(α)+z(β))

# ╔═╡ b483cae5-0b9f-43c3-b5c1-661ecc1ad176
n_calc = ceil(((z(α)+z(β))/(z(p₁)-z(p₂)))^2)

# ╔═╡ 53a23b68-8f87-4caf-a2e1-eda100a63f94
md"""
Comprobamos como la curva característica de operación, se aproxima a los riesgos de productor y del comprador, aunque no llega a cruzarlos como cuando resolvíamos el sistema de ecuaciones numéricamente.
"""

# ╔═╡ 616b4d97-337a-44b6-b58e-dc100f00aff4
begin
	plot(0:.001:.1, p->Pa(n_calc, k_calc, p), lw=2, ylabel="Pₐ", xlabel="p", legend=false)
	scatter!([p₁, p₂], [1-α, β])
	annotate!(p₁, 1-α, (" PRP", 10, :left, :bottom))
	annotate!(p₂, β, (" CRP", 10, :left, :bottom))
end

# ╔═╡ a83a87fb-121f-4d23-be5b-658dc63d53e7
md"""
### Criterio de aceptación

Realizar un muestreo por variables, supone:

1. Tomar una muestra aleatoria y libre de errores sistemáticos de _n_ unidades. 
2. Encontrar la media ($\bar{X}$) a partir de la medida del parámetro de calidad de cada una de las unidades de la muestra.
3. Aplicar el criterio de aceptación es:
"""

# ╔═╡ d17f56f6-4952-4902-aafa-bceb9f2a378e
Diagram(:mermaid, """
graph TD
A[Muestreo] --> B{"x̄ ≥ L+kσ"}
B --> |"Sí"|C[Se acepta]
B --> |"No"|D[Se acepta]
""")

# ╔═╡ 5bbd3a37-c7ac-47c4-8bb5-ee44f0f9924e
md"""
Vemos un ejemplo, se toma la muestra de _n_ = $(n_calc) unidades, se mide el parámetro de calidad y se obtienen los siguientes resultados:
"""

# ╔═╡ b2d3a39c-f002-4b3b-8d90-ea8e415080e3
begin
	# Aumentamos ligeramente la media de la muestra para que la Pₐ tenga un
	# valor más cercano a 0.5
	muest_dist_acep = Normal(μ+.1σ, σ/n_calc^.5)
	muestra_acep = [rand(muest_dist_acep) for i in 1:n_calc]
end

# ╔═╡ 313b5cf2-d9a0-4f68-8262-c583dda95e8c
md"""
Calculamos la media:
"""

# ╔═╡ bd192dec-5a8e-4a7f-8d0f-85dc3a32b959
x̄_acep = mean(muestra_acep)

# ╔═╡ 713232a1-76e6-4a69-9281-9a478424c2b3
md"""
y la comparamos con el criterio de aceptación:
"""

# ╔═╡ 99d57399-111f-4b14-9b75-a2a870827605
L + k_calc*σ

# ╔═╡ 4905d8ad-98e0-45bc-bf5c-253ccd0c6b18
md"""
El resultado es que el lote se debe **$(x̄_acep > L + k_calc*σ ? "aceptar" : "rechazar")**.
"""

# ╔═╡ ee5229d8-04a6-4626-becb-6b0306db6130
md"""
### Situación conflictiva

Una de los posibles inconvenientes de utilizar un plan de muestreo por variables es que se puede dar el caso de tenes una muestra con todas las unidades correctas, pero que el resultado del plan de muestreo sea que hay que rechazar el lote.

Veamos un ejemplo, este es el límite de calidad inferior _L_, criterio de aceptación  _k_ y desviación estándar histórica _σ_:
"""

# ╔═╡ 8483c411-dfca-4085-bcce-11fe880ea0f7
L_conf = 3.4

# ╔═╡ 45feb950-a7fc-41cb-821c-d6d36b5508b8
k_conf = 1.69

# ╔═╡ b8d01050-e674-4d5b-88b6-bf75062bc3ed
σ_conf  = 1.5

# ╔═╡ 8a876cb0-a7f2-4d2d-9c7c-4f03a136d500
md"""
Tomamos una muestra de 19 unidades y comprobamos que todas tienen un valor superior al del límite inferior de especificaciones:
"""

# ╔═╡ 3964d5c8-79a8-4497-975b-015ed980346b
muestra_conf= round.([4.66669

4.43438

4.55611

4.53688

5.27908

4.40256

5.25735

4.78645

5.02795

4.82112

4.85183

4.78652

4.78093

4.87119

4.93549

4.38844

4.93681

4.77289

5.14157]; digits=2) .+ 0.75

# ╔═╡ 75b6a00c-5c18-444e-aca6-1388057b2315
md"""
Aplicamos el criterio de aceptación y vemos que $\bar{X}$ es $(round(mean(muestra_conf); digits=3)) inferior al criterio de aceptación, _L_ + _kσ_, que es $(round(L_conf + k_conf*σ_conf; digits=3)), lo que supone que se debe **rechazar** el lote, aunque todas las unidades individuales de la muestra son correctas.

Esto puede ser un problema al rechazar un lote de un proveedor, ya que no tenemos resultados negativos de la muesta para mostrar.

La probabilidad de que esta situación ocurra baja:
"""

# ╔═╡ f2dcc877-5018-4beb-b1a9-458489dd944a
begin
	prob = 1
	for i in pdf.(muest_dist, muestra_conf)
		prob *= i
	end
	prob
end

# ╔═╡ 650c56e8-75ef-48d3-8e4d-0764381cd451
md"""
### Desviación estándar histórica desconocida

En esta situación, deberemos trabajar con _s_, la desviación estándar de la muestra, en lugar de con σ.

El calculo de _k_ se realizará como hemos visto arriba, pero para calcular el tamaño de muestra, lo más simple es utilizar la aproximación de Wallis:

$$\begin{align}
k &= \frac{z_{p_2} z_\alpha+z_{p_1}z_\beta}{z_\alpha+z_\beta}\\
n &= \left\lceil \left(\frac{z_\alpha+z_\beta}{z_{p_1}-z_{p_2}} \right)^2  \left( 1+ \frac{k^2}{2} \right)\right\rceil
\end{align}$$
"""

# ╔═╡ 527e664e-1095-4d69-abcf-d0d6690fb825
md"""
### Procedimiento M
#### _σ_ conocida
Se utiliza cuando existen límites bilaterales, _L_ y _U_. El método se basa en comparar la estimación de fracción de unidades no conformes de la muestra ($\hat{p}$) con el criterio de aceptación _M_, la proporción máxima de unidades no conformes tolerable.

|           | Atributos | Variables 
|-----------|:-----------:|:-----------:
|Método _k_ | $d \le c$ | $z=\frac{U-\bar{X}}{\sigma} \ge k$
|Método _M_ | $p = \frac{d}{n} \le \frac{c}{n} = M$ |  $Q=\frac{U-\bar{X}}{\sigma} \Rightarrow p \le M$

Para calcular _M_:

$$M=\int_{k\sqrt{\frac{n}{n-1}}}^\infty \frac{1}{\sqrt{2 \pi}} \mathrm{e}^{-\frac{t^2}{2}} \mathrm{d}t$$

!!! nota "Nota"

	La integral parece muy compleja pero no es más que el complementario de la función acumulada de la distribución normal estándar.

A continuación calcularemos los valores de _Q_:

$$\begin{align}
	Q_U = \frac{U-\bar{X}}{s} \sqrt{\frac{n}{n-1}}\\
	Q_L = \frac{\bar{X}-L}{s} \sqrt{\frac{n}{n-1}}
\end{align}$$

Si la desviación estándar es conocida (en ese caso, usaremos en las ecuaciones anteriores σ en lugar de _s_), con estos valores $Q_L$ y $Q_U$ podemos calcular la proporción de disconformidades con el área superior de la distribución normal estándar (la misma integral que hemos usado para encontrar _M_, pero tomando el valor de _Q_ como límite inferior de la integral).

"""

# ╔═╡ ba7addbe-77e1-466e-8ee4-1f006dc1f6e3
md"""
Estos son los datos de los que disponemos:
"""

# ╔═╡ 47c21d66-b00f-42f3-8c62-d898e30af903
k₂ = 1.6094

# ╔═╡ d532853a-ac20-4663-aff9-3863afc6ebe7
L₂ = 100

# ╔═╡ e6c0c59f-c23c-40b4-868c-bd80406bc37e
n₂ = 10

# ╔═╡ 10ba455f-b197-4d62-8450-4d31907fd992
σ₂ = 8

# ╔═╡ c1a1516f-90f2-4b7c-84ce-c7b62f8ff495
x̄₂ = 110

# ╔═╡ 0dafa148-ac20-4e69-83db-4e481acf5e72
cm"""
Veamos un ejemplo de aplicación tomado del libro de [Lawson](https://bookdown.org/lawson/an_introduction_to_acceptance_sampling_and_spc_with_r26/variables-sampling-plans.html):

!!! note "Ejemplo"

	Un plan de muestreo por variables tiene un valor de _k_ = $(k₂), tamaño de muestra _n_ = $n₂. El límite inferior de especificaciones es _L_ = $L₂, y la desviación estándar histórica _σ_ = $σ₂. Es toma una muestra y se obtiene un valor ``\bar{X}`` = $x̄₂. ¿Se debe aceptar el lote?
"""

# ╔═╡ 0ef077d6-c0f6-467d-9568-cde3c203b30b
md"""
En primer lugar calculamos $Q_L$:
"""

# ╔═╡ c037bd80-ff1f-4755-9c92-d197d453e335
QL = (x̄₂-L₂)/σ₂*sqrt(n₂/(n₂-1))

# ╔═╡ 085d2c80-d052-4d2e-aaa6-c37a43be0527
md"""
La fracción de disconformidades de la muestra $\hat{p}$:
"""

# ╔═╡ 780ce7a4-491b-46a8-9e0e-76ffdb0a9d0a
 p̂ = ccdf(Normal(), QL)

# ╔═╡ d3801a90-a77e-4501-8a38-78c04e329be0
md"""
En segundo lugar, calculamos _M_:
"""

# ╔═╡ b92cca08-ebbd-4e06-a7df-78e5d517d197
M₂ = ccdf(Normal(), k₂*(n₂/(n₂-1))^.5)

# ╔═╡ 3ea7588b-c263-47d2-a542-7340be8bd061
md"""
Se rechaza ya que la estimación de de fracción de disconformiadades de la muestra (_p̂_) es mayor que la permitida por el LIE (_M_).
"""

# ╔═╡ 5ede024a-6829-4f4f-943f-6bbb5e35b8f4
md"""
#### _σ_ desconocida

Los valores estimados son:

$$\hat{p}_U = I_x(a, a)$$

donde

$$\begin{gather}
x = \max \left\{ 0, \frac{1}{2}(1-Q_U)\right\}\\
a = \frac{n}{2}-1
\end{gather}$$

y

$$\hat{p}_L = I_x(a, a)$$

donde

$$\begin{gather}
x = \max \left\{ 0, \frac{1}{2}(1-Q_L) \right\}\\
a = \frac{n}{2}-1
\end{gather}$$

Finalmente, estima la fracción total de unidades disconformes, $\hat{p}$:

$$\hat{p}_L + \hat{p}_U = \hat{p}$$

El criterio de aceptación _M_, la fracción de unidades disconformes máxima tolerable es:

$$M = I_{B_M}( a, a)$$

donde:

$$B_M = \frac{1}{2}\left(1-k\frac{\sqrt{n}}{n-1}\right)$$

Si $\hat{p} \le M$, se acepta el lote.
"""

# ╔═╡ fbab45d8-ff04-4d14-9fbe-12ac42afff1a
Uₘ = 7

# ╔═╡ e93edece-0239-4693-a79a-7843e066229a
Lₘ = 5

# ╔═╡ 794759a2-ba7b-45b4-80d2-d607cbbe7131
cm"""
!!! note "Ejemplo"

	Un producto tiene como especificaciones _U_ = $Uₘ y _L_ = $Lₘ. Se desea seleccionar un plan de muestreo para p₁ = $p₁, α = $α, p₂ = $p₂ y β = $β. No se dispone de la desviación estándar histórica.

Los datos del ejemplo son:
"""

# ╔═╡ d6e6479b-f513-45bb-a821-b496e6b97a87
p₁

# ╔═╡ b2708608-2862-45ca-acf5-d184fba4672c
p₂

# ╔═╡ 78fa3c02-9fdf-43f2-9120-e5e6e985afb7
α

# ╔═╡ 660d6fc5-1eb9-4616-91f1-c62afa4697a4
β

# ╔═╡ 2a482e8b-d3f1-436e-bc64-c9f6b4e9482a
md"""
En primer lugar calcularemos _k_ y _n_ de igual manera que en el proceso k:
"""

# ╔═╡ fd358f0d-f68e-4c36-bf52-df895167800f
kₘ = (z(p₂)*z(α)+z(p₁)*z(β))/(z(α)+z(β))

# ╔═╡ c90b7d43-7756-47a9-afb6-44ecb552e316
nₘ = ceil(((z(α)+z(β))/(z(p₁)-z(p₂)))^2*(1+kₘ^2/2))

# ╔═╡ d70934f6-3309-4c1f-ba26-76251104445e
md"""
Usando el procedimiento M, determinaremos _M_:
"""

# ╔═╡ 382d5f51-1072-4317-a813-af6e3692ff2e
B(a, x) = cdf(Beta(a), x)

# ╔═╡ 490f4304-b6fa-492e-91bc-d8f2409c6fdd
aₘ = nₘ/2-1

# ╔═╡ edcb45d2-ac52-4cea-b388-640f9dcec294
Bₘ = 1/2*(1-kₘ*sqrt(nₘ)/(nₘ-1))

# ╔═╡ f5fded7d-f84f-4c5a-8590-96fb8f5db108
Mₘ = B(aₘ, Bₘ)

# ╔═╡ 6e98a353-2f6a-4072-b905-6c326d5dbeb7
md"""
!!! note "Nota"

	El cálculo de _M_ se puede realizar utilizando [WolframAlpha](https://www.wolframalpha.com) con las instrucción `cdf[betadistribution[30, 30], 0.373123]`.
"""

# ╔═╡ 2b13dc37-787d-466c-851a-0f02c21716bc
md"""
Vamos a ver como se utizaría el criterio de aceptación. Simulamos un muestreo y obtenemos al analizar el parámetro de calidad los siguientes valores:
"""

# ╔═╡ c608f660-49a5-4546-965d-092e2204a2fa
muestraₘ = [rand(Normal(6, .5)) for i in 1:nₘ]

# ╔═╡ c621ae1f-a296-4a8f-bce8-8466c87270b7
md"""
Calculamos el valor medio de la muestra y su desviación estándar:
"""

# ╔═╡ cbeac826-dd9c-43f1-b6fb-462eac037ebc
X̄ₘ = mean(muestraₘ)

# ╔═╡ 825a7169-0091-4471-8dff-d639c2929d07
sₘ = std(muestraₘ)

# ╔═╡ f3f0b51e-021b-436f-9229-6c6ab4c73f95
md"""
Con los límites de especificaciones calculamos $Q_U$ y $Q_L$:
"""

# ╔═╡ 2bc3876e-ec58-4439-ba34-a62ee2607cc5
Qᵤ = (Uₘ-X̄ₘ)/sₘ*sqrt(nₘ)/(nₘ-1)

# ╔═╡ dd2da4b6-e789-4671-9471-f17e5865b19c
Qₗ = (X̄ₘ-Lₘ)/sₘ*sqrt(nₘ)/(nₘ-1)

# ╔═╡ 81989a43-957f-42f0-bc54-324cd1180c33
md"""
Ya solo queda calcular p̂₁ y p̂₂ y aplicar el criterio de aceptación.
"""

# ╔═╡ 09aad6b6-ec6c-42d7-b930-1e348ba93682
xᵤ = 1/2-1/2*Qᵤ

# ╔═╡ 07144710-6b61-45ba-b324-a752331fea87
p̂ᵤ = B(aₘ, xᵤ)

# ╔═╡ b6dd8601-77ca-423e-afc4-004e1582583e
xₗ = 1/2-1/2*Qₗ

# ╔═╡ afed40e4-db49-4eca-90c8-ea521737af89
p̂ₗ = B(aₘ, xₗ)

# ╔═╡ 87d48068-d180-457e-b19b-29486b64a226
p̂ₘ = p̂ₗ + p̂ᵤ

# ╔═╡ 47184915-65c3-49ff-9031-fba150f349e7
p̂ₘ <= Mₘ

# ╔═╡ 0cf12f11-91d6-44e2-867b-07bcdcdeffe5
md"""
El resultado es que hay que **$(p̂ₘ <= Mₘ ? "aceptar" : "rechazar")** el lote.
"""

# ╔═╡ 1df70d3d-8d82-4a3c-92ea-72ba49ad7620
md"""
---
"""

# ╔═╡ 04b4e313-141b-4069-9d36-a7005275e4ce
PlutoUI.TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Kroki = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
NLsolve = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
CommonMark = "~0.8.7"
Distributions = "~0.25.79"
Kroki = "~0.2.0"
Latexify = "~0.15.17"
NLsolve = "~4.5.1"
Plots = "~1.37.2"
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0-rc3"
manifest_format = "2.0"
project_hash = "c4bfefe4609908be48454bbdc89a783de6295f19"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "badccc4459ffffb6bce5628461119b7057dec32c"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.27"

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
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
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
git-tree-sha1 = "73e9c4144410f6b11f2f818488728d3afd60943c"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.9"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

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
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "c5b6685d53f933c11404a3ae9822afe30d522494"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.2"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

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

[[deps.FiniteDiff]]
deps = ["ArrayInterfaceCore", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "04ed1f0029b6b3af88343e439b995141cb0d0b8d"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.17.0"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "a69dd6db8a809f78846ff259298678f0d6212180"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.34"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "051072ff2accc6e0e87b708ddee39b18aa04a0bc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "501a4bf76fd679e7fcd678725d5072177392e756"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.1+0"

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
git-tree-sha1 = "97b6c88f4df0ff821a6d93dbdcdf9642e66fa718"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.6.1"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
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
version = "2.28.2+0"

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
version = "2022.10.11"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

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
version = "0.3.21+4"

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
version = "10.42.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

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
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

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
git-tree-sha1 = "dadd6e31706ec493192a70a7090d369771a9a22a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.37.2"

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

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

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
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "ffc098086f35909741f71ce21d03dadf0d2bfa76"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.11"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

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

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

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
version = "1.2.13+0"

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
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

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
# ╟─9052c977-954c-4378-a5ef-1578120ca434
# ╠═d4375a7c-40ca-4c18-a004-04b72c6c264e
# ╠═563743e6-5388-4465-ade9-c2ff3347e50f
# ╟─e7a45ca1-1471-4d45-8ccf-84b71ca300de
# ╠═6ed24594-b711-4127-a114-5eceeb2aee45
# ╟─26da1373-0dda-474b-a680-4a4fbcf89424
# ╠═8c23af09-ab77-40ea-b98c-f89a6433909b
# ╠═c06be3c1-6bf1-4995-8da2-0239a4a30e8a
# ╟─0c656691-5c9c-41d9-8b40-3a44c6243f1f
# ╠═f56b1e9f-91ad-4eba-8ec9-82732e904d74
# ╟─8109a0fc-6ed9-43f7-8549-a1382218f12d
# ╠═3ce19bcd-2574-4db2-8091-27a2dc33974f
# ╟─b0a13203-f9bf-44cb-b5b7-1396d889715b
# ╟─787f1b94-ee8c-4a16-9da0-e917a14352cb
# ╠═12c01d45-86c7-4781-8547-0d1c6c092c15
# ╟─8027a81c-6d70-4376-9725-dc2ae8474acb
# ╠═0b4fd00c-73a7-4bdb-9e86-50d9ffef05da
# ╟─d006f3f5-6394-4e37-ba2b-fad9bceae446
# ╠═01060c3b-558d-4046-8ab2-25c813048c61
# ╟─48d9c3bc-33de-4b66-85fd-c32ede2f8842
# ╟─dccf9cf1-41c5-4e21-ab6f-d6c3b3044b98
# ╟─a12bca4a-d8db-4306-9e8c-d5f1510acbc7
# ╟─cfff154a-bc17-4d7e-bf48-f09a71dc184f
# ╟─da28f29d-4236-495d-a3eb-35073ae194d7
# ╠═7b1ceee8-1006-49b9-8dcd-cfecab969887
# ╟─663a2370-c1de-4359-937d-f2e54f0aa8c1
# ╟─ddac22e6-2f5d-4c8f-8f63-738d836591f8
# ╟─ff1657e8-0b38-4d4c-8f8a-1478bb7ff672
# ╟─bb18d41a-bcf6-4397-b11a-4c6586d53411
# ╟─c174a54e-19ed-4de4-b8a7-6837cd8a9118
# ╟─c805d759-6506-4b4e-8a89-930eb481d1c9
# ╟─9361ef96-f92e-4608-a91a-57d9b6ff8fb5
# ╟─054989a7-427e-45fe-a475-67ca8b065207
# ╟─3362bced-65a0-49d9-b503-7111e7122297
# ╟─63191c40-9860-470b-908a-bc167e34df3c
# ╟─bb399108-b88a-40bf-984e-35fcbf146480
# ╟─2c982a39-d9a7-43f7-b3a7-ace5e7e630fa
# ╟─c9580937-f448-4375-9c7f-902c7b84d5f6
# ╟─87028070-d3fa-4435-8205-c5f523a91695
# ╟─0c747e5a-4218-41a5-b5b8-57916db7bec7
# ╟─ba126afa-6f7b-43b3-b1b6-57c5e4a9e457
# ╟─ba5f4420-1e38-4d58-94dd-7ea17cf2f81a
# ╟─86db4e39-52a1-4cf0-8dfa-b9d5cef8f8ae
# ╟─4c1fb69a-123b-4909-8015-208107c0e955
# ╟─7b9bccb4-13da-4c04-acc2-311a947de6c2
# ╟─48ac993c-93fb-4f2e-83be-3f13dd00572e
# ╠═f7fe9643-6c15-477e-b648-e48bfc36c2f5
# ╟─7399ecb3-7271-4c60-b277-4513b9efdc12
# ╟─2f676820-3b6c-480c-8dc9-2464cb176d43
# ╟─a0d6a372-1529-4c57-b2a5-8d51c5c048fa
# ╠═8bd2329b-0085-4852-b3ac-d05cb2995e71
# ╠═c7852b2d-0dc9-4c8a-8f0a-9f14b16f5417
# ╠═c93a6041-4686-46e3-bedc-a4a4c4b2274f
# ╠═2b7f1b6b-5f60-43df-a531-f450542a27af
# ╟─48b430ac-237e-4426-9b00-e2503e5397db
# ╠═8e09ee89-21ef-4a71-95b6-6eb08d8e74ad
# ╠═abbcb6ad-72d3-4fef-a41e-72e8c33506d3
# ╠═3dcc22f0-ac38-4df6-b863-376d73b88d6a
# ╟─424d7e13-0112-4db3-957c-8b066d19f21e
# ╟─021e4511-28a8-4d9d-b889-6a70b9a0a831
# ╟─be08a856-8d4c-4dc5-9c60-09ecee98318d
# ╟─feb81ece-6503-4a46-b448-235f50434284
# ╟─d7b270c1-8f3f-4ea1-99c0-95e20ae94474
# ╟─04af219e-0f6c-4f0f-905f-fbecd1daed44
# ╟─e3289b5d-4119-45d7-9582-19be179702e7
# ╠═0e2add63-2ad1-4ffa-93a8-f5889dc5fc89
# ╠═0348d00a-45f3-4b11-9a9b-23289d9026c6
# ╠═b483cae5-0b9f-43c3-b5c1-661ecc1ad176
# ╟─53a23b68-8f87-4caf-a2e1-eda100a63f94
# ╟─616b4d97-337a-44b6-b58e-dc100f00aff4
# ╟─a83a87fb-121f-4d23-be5b-658dc63d53e7
# ╟─d17f56f6-4952-4902-aafa-bceb9f2a378e
# ╟─5bbd3a37-c7ac-47c4-8bb5-ee44f0f9924e
# ╟─b2d3a39c-f002-4b3b-8d90-ea8e415080e3
# ╟─313b5cf2-d9a0-4f68-8262-c583dda95e8c
# ╠═bd192dec-5a8e-4a7f-8d0f-85dc3a32b959
# ╟─713232a1-76e6-4a69-9281-9a478424c2b3
# ╠═99d57399-111f-4b14-9b75-a2a870827605
# ╟─4905d8ad-98e0-45bc-bf5c-253ccd0c6b18
# ╟─ee5229d8-04a6-4626-becb-6b0306db6130
# ╠═8483c411-dfca-4085-bcce-11fe880ea0f7
# ╠═45feb950-a7fc-41cb-821c-d6d36b5508b8
# ╠═b8d01050-e674-4d5b-88b6-bf75062bc3ed
# ╟─8a876cb0-a7f2-4d2d-9c7c-4f03a136d500
# ╟─3964d5c8-79a8-4497-975b-015ed980346b
# ╟─75b6a00c-5c18-444e-aca6-1388057b2315
# ╠═f2dcc877-5018-4beb-b1a9-458489dd944a
# ╟─650c56e8-75ef-48d3-8e4d-0764381cd451
# ╟─527e664e-1095-4d69-abcf-d0d6690fb825
# ╟─0dafa148-ac20-4e69-83db-4e481acf5e72
# ╟─ba7addbe-77e1-466e-8ee4-1f006dc1f6e3
# ╠═47c21d66-b00f-42f3-8c62-d898e30af903
# ╠═d532853a-ac20-4663-aff9-3863afc6ebe7
# ╠═e6c0c59f-c23c-40b4-868c-bd80406bc37e
# ╠═10ba455f-b197-4d62-8450-4d31907fd992
# ╠═c1a1516f-90f2-4b7c-84ce-c7b62f8ff495
# ╟─0ef077d6-c0f6-467d-9568-cde3c203b30b
# ╠═c037bd80-ff1f-4755-9c92-d197d453e335
# ╟─085d2c80-d052-4d2e-aaa6-c37a43be0527
# ╠═780ce7a4-491b-46a8-9e0e-76ffdb0a9d0a
# ╟─d3801a90-a77e-4501-8a38-78c04e329be0
# ╠═b92cca08-ebbd-4e06-a7df-78e5d517d197
# ╟─3ea7588b-c263-47d2-a542-7340be8bd061
# ╟─5ede024a-6829-4f4f-943f-6bbb5e35b8f4
# ╟─794759a2-ba7b-45b4-80d2-d607cbbe7131
# ╠═fbab45d8-ff04-4d14-9fbe-12ac42afff1a
# ╠═e93edece-0239-4693-a79a-7843e066229a
# ╠═d6e6479b-f513-45bb-a821-b496e6b97a87
# ╠═b2708608-2862-45ca-acf5-d184fba4672c
# ╠═78fa3c02-9fdf-43f2-9120-e5e6e985afb7
# ╠═660d6fc5-1eb9-4616-91f1-c62afa4697a4
# ╟─2a482e8b-d3f1-436e-bc64-c9f6b4e9482a
# ╠═fd358f0d-f68e-4c36-bf52-df895167800f
# ╠═c90b7d43-7756-47a9-afb6-44ecb552e316
# ╟─d70934f6-3309-4c1f-ba26-76251104445e
# ╠═382d5f51-1072-4317-a813-af6e3692ff2e
# ╠═490f4304-b6fa-492e-91bc-d8f2409c6fdd
# ╠═edcb45d2-ac52-4cea-b388-640f9dcec294
# ╠═f5fded7d-f84f-4c5a-8590-96fb8f5db108
# ╟─6e98a353-2f6a-4072-b905-6c326d5dbeb7
# ╟─2b13dc37-787d-466c-851a-0f02c21716bc
# ╠═c608f660-49a5-4546-965d-092e2204a2fa
# ╟─c621ae1f-a296-4a8f-bce8-8466c87270b7
# ╠═cbeac826-dd9c-43f1-b6fb-462eac037ebc
# ╠═825a7169-0091-4471-8dff-d639c2929d07
# ╟─f3f0b51e-021b-436f-9229-6c6ab4c73f95
# ╠═2bc3876e-ec58-4439-ba34-a62ee2607cc5
# ╠═dd2da4b6-e789-4671-9471-f17e5865b19c
# ╟─81989a43-957f-42f0-bc54-324cd1180c33
# ╠═09aad6b6-ec6c-42d7-b930-1e348ba93682
# ╠═07144710-6b61-45ba-b324-a752331fea87
# ╠═b6dd8601-77ca-423e-afc4-004e1582583e
# ╠═afed40e4-db49-4eca-90c8-ea521737af89
# ╠═87d48068-d180-457e-b19b-29486b64a226
# ╠═47184915-65c3-49ff-9031-fba150f349e7
# ╟─0cf12f11-91d6-44e2-867b-07bcdcdeffe5
# ╟─1df70d3d-8d82-4a3c-92ea-72ba49ad7620
# ╠═7018db2a-60d1-11ed-2d8a-35c1275879bc
# ╠═04b4e313-141b-4069-9d36-a7005275e4ce
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
