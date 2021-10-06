### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ ae0f4b49-de27-4ec1-8d3e-de41a6b95abb
using PlutoUI, Plots, LaTeXStrings, Distributions, NamedArrays, JuMP, COSMO, DataEnvelopmentAnalysis

# ╔═╡ 1bb58003-a908-4658-bce9-67b892cec480
html"<button onclick='present()'>present</button>"

# ╔═╡ 734f53b8-35df-4da3-a4e3-dc4718239ba0
begin 
	struct TwoColumn{L, R}
    left::L
    right::R
	end

	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
		write(io, """<div style="display: flex;"><div style="flex: 50%;">""")
		show(io, mime, tc.left)
		write(io, """</div><div style="flex: 50%;">""")
		show(io, mime, tc.right)
		write(io, """</div></div>""")
	end
end

# ╔═╡ 9a2e6ed7-a398-4717-9a95-732b0337405e
md"""
Acknowledgements: The structure and technical proofs of this tutorial comes from _Ray, S. C. (2004). Data envelopment analysis: theory and techniques for economics and operations research. Cambridge university press._
"""

# ╔═╡ 6bf52b00-1881-11ec-2ec9-85c3a45c0752
md"""
# Evaluating Firms Environmental Performance
+ What is Environmentals?
+ What is Environmental Performance?
+ How to Evaluate Performance? A Simple Approach
+ Parametric vs. Non-Parametric Approach
+ The Absence of Market Prices
+ Data Envelopment Analysis
+ DataEnvelopmentAnalysis.jl
"""

# ╔═╡ 4d6245c1-566d-4f90-9083-0a61d119dbed
md"""
## What is Environmentals?

Let's start with the Environmentals issues listing from the _Value Balancing Alliance_:
+ Greenhouse gas emissions
+ Air pollution
+ Water consumption
+ Water pollution
+ Land use
+ Waste

"""

# ╔═╡ 7b32a506-aae5-4af5-ad1f-3a16301d7a2c
md"""
## What is a Firm Environmental Performance?

Let's simply define a firm environmental performance:
+ Environmentals are inputs used in the production process
+ Sales are the output from the production process
+ Taking an input-focused approach: for a sales value, the closer the actual environmentals consumption from the minimum value attainable is, the greater is its environmental performance
"""

# ╔═╡ 3e0dc5d4-ee2b-462a-8f39-ba15c164b5a7
md"""
## Descriptive vs. Normative Measurement of Environmental Performance
Two concepts are commonly used to characterize performance:
+ Productivity
+ Efficiency
However, these two concepts are fundamentally different.
**Productivity** is a **descriptive** measure of performance while **efficiency** is a **normative** one.
"""

# ╔═╡ b84cfdb6-855b-4c13-871c-a495a68495a3
@bind slider_sales_A Slider(1:20, default = 6)

# ╔═╡ 13df1f5c-07a7-4528-8dcc-cf650faa520c
@bind slider_GHG_A Slider(1000:1000:20000, default = 2000)

# ╔═╡ d36b49c9-f9b7-4e60-a084-ce7569544fd0
@bind slider_sales_B Slider(1:20, default = 3)

# ╔═╡ 66ed22ac-a715-4ecb-98be-66403e62b486
@bind slider_GHG_B Slider(1000:1000:20000, default = 2000)

# ╔═╡ 210a0931-91e4-4a4e-8ed4-1be890455b3f
md"""
## Productivity as a Descriptive Measurement of Environmental Performance

Let's take an example with the 2 companies: 
+ Company A's Sales are at $slider_sales_A million USD
+ Company A's GHG emissions stand at $slider_GHG_A tonnes of C02 equivalent
+ Company B's Sales are at $slider_sales_B million USD
+ Company B's GHG emissions stand at $slider_GHG_B tonnes of C02 equivalent

"""

# ╔═╡ 4e7045a5-5b82-4af1-9199-f06c99e2692d
begin
	AP_A = round(slider_sales_A / slider_GHG_A; digits = 4);
	AP_B = round(slider_sales_B / slider_GHG_B; digits = 4);
end;

# ╔═╡ 7ac93c3e-7385-49e3-8a03-bbfebeb862b0
md"""
In that case, what is average productivity?
Well, because we supposed this is a single-output / single-output technology, the **average productivity is as simple as the ratio of the output and the input**:

``AP_A = \frac{y_A}{x_A}= ``$AP_A

``AP_B = \frac{y_B}{x_B}= ``$AP_B

But, looking at each average productivity independently, it doesn't say anything about the environmental performance: this is a descriptive measure only!
To get a sense of the environmental performance, one should compare company A and company B average productivies for example.
"""

# ╔═╡ 5c88a644-473f-4f81-87bd-b2a5856a539c
@bind slider_GHG_min Slider(500:100:2000, default = 600)

# ╔═╡ 533fd3d5-dce3-4d87-b251-09ed696fb9d1
md"""
## Efficiency as a Normative Measurement of Environmental Performance

Now let's imagine we do know the **technology** (that is, in our case, how much GHG needs to be emitted at the minimum level for the production process) in the sector where these firms operates, which is describe by a production function:

``x^* = f(y)``

Where ``x^*`` is the minimum GHG emissions level for a Sales amount.
We can measure **the efficiency of a firm by comparing its actual GHG emissions with the minimum level of GHG emissions for the same Sales amount.** As we are targeting the mininimum GHG emissions level or input consumption here, this is an **input-oriented** or **input-saving** measure of efficiency.

Doing so, we are **evaluating** the performance of the firm.

Let's define a value for ``x_A^*`` (_ie._ the minimum GHG emissions for the same level of Sales than company A) as an illustration:

``x_A^* = `` $slider_GHG_min
"""

# ╔═╡ 8642a6f6-0185-4f07-8689-725356c7b2c7
md"""
**The closer the efficiency is to 1, the more efficient the firm is**.
"""

# ╔═╡ 5319b650-e0a4-40ec-b0de-39a542142e16
begin
	TE_A =  slider_GHG_min / slider_GHG_A 
	TE_B = slider_GHG_min / slider_GHG_B
end;

# ╔═╡ 70b18cb1-56f0-4d08-b29e-ff8259fd7886
md"""
Which gives the following efficiency value for our company A:

``E_A = \frac{x^*_A}{x_A} = `` $TE_A

"""

# ╔═╡ 4c33d74d-4a48-4be7-b1f0-8fd9edcf19a8
md"""
## How to Compute Efficiency in Practice?
We said that, contrary to the average productivity, one should know the underlying technology in order to compute efficiency (_ie._ what is the minimum level of GHG emissions for a certain amount of Sales in our case). We've also addressed the simple one Environmental issue (namely GHG emissions) so far, but there are multiple Environmental issues.

We will take a look at two commonly used but different approaches:
+ A _Scoring_ approach, based on _Gaussian distribution_
+ A _Data Envelopment Analysis_ approach, based on the concept of _Efficiency Frontier_
For each indicator, we will take a look at:
+ How does the _Technology_ is estimated?
+ How to analyze the performance regarding multiple Environmentals issues?
"""

# ╔═╡ c86b8a58-5f84-42cf-b4ea-2d0a638588aa
md"""
## The Scoring Approach

The common scoring approach can be described as computing efficiency through relative productivity index. 

The idea is the following: starting from the average productivity, one can build a normative measure by comparing the average productivity to the distribution of the other companies average productivities.


"""

# ╔═╡ d59e0941-5b9f-40a4-8b52-f05e0df7494b
md"""
## Determining Technology with Scoring: a Parametric Approach

You need to specify the probability distribution.
"""

# ╔═╡ 2561df55-6aea-430f-9466-4c4a52a54990
md"""
## Multiple Inputs Case with the Scoring Approach
"""

# ╔═╡ 8ef5645f-c477-473c-9de9-d0c4c4bca856
md"""
## Data Envelopment Analysis Approach


Charnes, Cooper and Rhodes (1978, 1981) introduced the method of _Data Envelopment Analysis_ (DEA) to address the problem of efficiency measurement for *decision-making units* (DMUs) with multiple inputs and multiple outputs in the absence of market prices. 

Decision-making units is a term including nonmarket agents, like schools, or hospitals, producing identifiable and measurable outputs from measurable inputs, but lacking market prices of outputs and / or inputs. 
"""

# ╔═╡ 231d83b3-6706-4823-9cff-f0895a1dabc7
md"""
## Determining Technology with DEA: a Non-Parametric Approach (1/2)

In DEA, an **efficiency frontier** is constructed from the observed GHG emissions / Sales combinations of the firms in the sample, with no specification of an explicit form of the production function. The **frontier efficiency will be built upon the combination of firms located on the efficiency frontier**.
Let's take an example:
"""

# ╔═╡ b29369e6-d184-4741-ad57-739af4c9677f
begin
	companies = [string("Company ",i) for i in 1:5]
	col_names = ["Sales","GHG emissions"]
	sales = rand(1:1:20, length(companies))
	emissions = rand(1000:500:10000, length(companies))
	data_single_case = NamedArray([sales emissions], (companies, col_names), ("Firm", "Variable"))
	data_single_case[:,"Sales"] = round.(data_single_case[:,"Sales"] / mean(data_single_case[:,"Sales"]) * 1000; digits = 0)

	data_single_case[:,"GHG emissions"] = round.(data_single_case[:,"GHG emissions"] / mean(data_single_case[:,"GHG emissions"]) * 1000; digits = 0)
	data_single_case
end

# ╔═╡ 84b1e005-ea4f-46f6-a2f1-4919897268a4
md"""
Let's see the model for each company:

"""

# ╔═╡ 8515eb6f-cac7-4eca-a02e-fb1f07607324
@bind company_i Slider(1:1:5, default = 1)

# ╔═╡ 21040d14-f76c-48bb-8f17-da152450e609
begin
	# split 
	X = data_single_case[:,["GHG emissions"]]
	Y = data_single_case[:,["Sales"]]
	
	# number of inputs
	m = size(X,2)
	# number of outputs
	s = size(Y,2)
	
	# Declare the model
	i = company_i
	
	# value of input and output to evaluate
	x0 = X[[i],:]
	y0 = Y[[i],:]
	
	# number of companies
	n = 5
	
	# for results
	θ_star = NamedArray(zeros(1), ([i]), ("DMU","Efficiency"))
	λ_star = NamedArray(zeros(1, n), ([i],names(X,1)), ("DMU","Lambda"))
	
	# Create the JuMP model
	deamodel = Model(COSMO.Optimizer)
	@variable(deamodel, θ)
	@variable(deamodel, λ[1:n] >= 0)
	@objective(deamodel, Min, θ)
	@constraint(deamodel, [x in 1:m], sum(X[t,x] * λ[t] for t in 1:n) <= θ * x0[x])
	@constraint(deamodel, [y in 1:s], sum(Y[t,y] * λ[t] for t in 1:n) >= y0[y])
	
	# Optimize and return the results
	JuMP.optimize!(deamodel)
	θ_star[1] = JuMP.objective_value(deamodel)
	λ_star[1,:] = JuMP.value.(λ)
	GHG_targets = round(θ_star[1] * x0[1]; digits = 0)
	# print the model
	latex_formulation(deamodel)
end


# ╔═╡ d057a510-f3ea-45f2-9194-87d4c671e988
printed_theta = round(θ_star[1]; digits = 2);

# ╔═╡ 49a30cab-45fe-4ff7-b78f-0badee3c2122
md"""
## Determining Technology with DEA: a Non-Parametric Approach (2/2)
The optimal solution is for company $company_i :

``\theta^* = `` $printed_theta

Given the Sales amount of the company, the company should emit ``GHG ^* = \theta^* * GHG_A =``$GHG_targets tonnes of CO2 eq in order to be efficient.

And:
"""

# ╔═╡ 2aacf9af-b3f5-4637-bd57-ad2723c3d0d0
begin
	if printed_theta > 0.9
		efficient_or_not = "efficient as it is close or on the efficient frontier"
	else
		efficient_or_not = "is not efficient because it is far from the efficient frontier"
	end
	benchmark_weight = round(maximum(λ_star); digits = 2)*100
	company_eff = argmax(λ_star)[2]
	λ_star
end

# ╔═╡ 280cff5e-5be0-4362-972d-e6c033cdeafd
md"""
The efficient frontier for company $company_i correspond to a virtual company $company_i``^*`` which is built with $benchmark_weight% of company $company_eff.
"""

# ╔═╡ debae212-c156-47bd-b78a-01244febe926
md"""
Hopefully, this single input (GHG emissions) single output (Sales) can be represented graphically:
"""

# ╔═╡ 4b3eaa5e-9fda-4e24-81ee-aaaad80aaa24
begin
	dea_model_single_case = dea(Matrix(X), Matrix(Y), optimizer = DEAOptimizer(COSMO.Optimizer), orient = :Input, rts = :CRS)
	targets_X = targets(dea_model_single_case, :X)

end;

# ╔═╡ 14beb5b4-e92a-4c70-adf8-9a30c3d0dd70
begin
	targets_X_narray = NamedArray(targets_X, (companies, ["Target"]))
	data_for_graph = hcat(data_single_case, targets_X_narray)
	data_for_graph = data_for_graph[sortperm(data_for_graph[:, 2]), :]
	scatter(data_for_graph[:,2], data_for_graph[:,1], marker =:square, label = false, xlabel = "GHG Emissions", ylabel = "Sales")
	plot!(data_for_graph[:,3], data_for_graph[:,1], ylims = (0, maximum(data_for_graph[:,1]) + 1000), label = "Efficiency Frontier")
	scatter!(data_for_graph[:,3], data_for_graph[:,1], label = "Virtual Companies")
end

# ╔═╡ d19488e9-4cf5-4c9f-b70b-c57ba868a60f
md"""
## Multiple Inputs Case with the DEA Approach: the Concept of Shadow Prices

If the case with only GHG emissions as an input and Sales as an output is quite straightforward, DEA is more usefull in the case of multiple environmentals issues.

Indeed, if we consider the case where we want to analyze the environmental performance of a firm regarding both GHG emissions and Water consumption for example, one should consider how to suitably aggregate these issues.

In the absence of market prices, such as the case for Environmentals, the method of DEA can endogenously generates "_shadow prices_" for each issue. 
"""

# ╔═╡ 80bf800d-dbd0-4786-ab04-1900acfde278
md"""
## The Efficiency Frontier

Figure below gives a sens of the concept of efficiency and the difference between efficiency and productivity.

``P_A`` represents the combination between input and output for firm A. The average productivity of A is given by the slope of ``OP_A``. We have the same information for firm B.

To measure and compare average productivities of both companies, we do not need to know (in this case of single-input / single-output combination) anything beyond ``P_A`` and ``P_B``.

However, to determine the efficiency of the firm A, we need to know ``P_A^*`` measuring the maximum output producible ``y_A^*`` with the amount of input ``x_A``.

Location of this reference point depends on the production function ``f(x)``. The production function ``y = f(x)`` is the **frontier of the production possibility** defined by the technology. Points ``P_A^*`` and ``P_B^*`` are **vertical projections** of the points ``P_A`` and ``P_B`` onto the frontier.

In both cases, observed input amount are unchanged and the output level is expanded till we reach the frontier.
"""

# ╔═╡ 46c3247f-5fd2-427e-a77d-34a992497825
begin
	xs = [0, x_A, x_B]
	ys_star = [0, y_star_A, y_star_B]
	plot(xs, ys_star, label = L"y = f(x)",
		xlabel = L"Input(x)",
		ylabel = L"Output(y)", xlims =(0,100), ylims =(0,20))
	x_s_A = [0, x_A]
	y_s_A = [0, y_A]
	plot!(x_s_A, y_s_A, label = L"OP_A")
	x_s_B = [0, x_B]
	y_s_B = [0, y_B]
	plot!(x_s_B, y_s_B, label = L"OP_B")
	scatter!([x_A],[y_A], marker =:square, label = L"P_A")
	scatter!([x_B],[y_B], marker =:square, label = L"P_B")
	scatter!([x_A],[y_star_A], marker =:square, label = L"P_A^*")
	scatter!([x_B],[y_star_B], marker =:square, label = L"P_B^*")
end

# ╔═╡ a6c9df5b-638f-4f5d-8dc8-5b77987d77a1
md"""
Now let's play around and define a new ``y_A`` with the slider below:
"""

# ╔═╡ 79103498-20f7-44b3-98f9-8392edbae08e
@bind slider_y_A Slider(1:20, default = 6)

# ╔═╡ e7094a2c-2a82-4304-ac77-1d406eabd72f
md"""
And same with ``y_B``!
"""

# ╔═╡ bc0c5077-2db9-4046-aefb-28436b061400
@bind slider_y_B Slider(1:20, default = 8)

# ╔═╡ 23d4d2af-152a-4b61-93b7-e7592fb63c11
md"""
What if we move ``y^*_A``?
"""

# ╔═╡ 3bab3f20-50c5-4beb-a35d-444da1db238e
@bind slider_y_star_A Slider(0:10, default = 4)

# ╔═╡ 09edf76b-a194-4cd2-8851-7a730a70b16d
md"""
And ``y^*_B``?
"""

# ╔═╡ 43c4dd4a-479c-42e0-987b-804eb0a19d1d
@bind slider_y_star_B Slider(0:10, default = 6)

# ╔═╡ bf5e03fd-2bb4-4c47-a03f-0e6beab6b29e
md"""
Then take a look at the previous formula and see what are the new technical efficiency measurements!
"""

# ╔═╡ 8dc80971-b6a5-40da-8e7e-f496747f464a
md"""
An alternative of the output-oriented technical efficiency is the input-oriented approach: in that case, the output level remains unchanged and input quantities are reduced till the fontier is reached, points ``P_A^*`` and ``P_B^*`` are **horizontal projections** on to the frontier.

Below are sliders to let you make an assumption regarding ``x_A^*`` and ``x_B^*``. Please note that assuming an ``x_A^*`` and ``x_B^*`` independently of our previous assumptions regarding an ``y_A^*`` and an ``y_B^*`` would yield a different efficiency frontier!
"""

# ╔═╡ 6a2849f9-c079-461f-a7d4-4fc9ecdbe271
md"""
Let's define ``x_A^*``:
"""

# ╔═╡ d4580ae3-5e82-4afa-8c66-e19099706ec7
md"""
And ``x_B^*``:
"""

# ╔═╡ bf84d0b3-20c5-4678-8cb9-4c409a336896
md"""
## Evaluating Performance in the Absence of Market Prices & Parametric vs. Non-parametric methods
Some shortfalls from traditional approaches call for the use of a more robust methodology to evaluate performance. Some of these shortfalls are:
+ The Multiple-Input / Multiple-Output Case
+ Parametric vs. Nonparametric methods

"""

# ╔═╡ cf18e352-5493-4f2b-8f68-93b1c2d38ac1
md"""
#### Multiple-Input / Multiple-Output Case in the Absence of Market Prices
Outside the roughly simplified example with a single-input / single-output technology, the concept of average productivity measured by the output-input ratio is no longer usefull.

Let's suppose that firm A uses ``x_{1,A}`` of input 1 and ``x_{2,A}`` of input 2. Same reasoning for firm B. We now have two different sets of average productivities:

``AP^1_A = \frac{y_A}{x_{1,A}}``

and

``AP^2_A = \frac{y_A}{x_{2,A}}``

In that case, **measuring a firm's productivity relying on a single input disregarding other inputs is simply wrong**! Indeed, a firm's average productivity relative to one input depends on the quantity of the other input as well.

In this single-output, multiple-input case, we need to aggregate the individual input quantities into a **composite input** before computing an average productivity.
One approach uses market prices of inputs for aggregation. 
"""

# ╔═╡ 934f70b5-5871-4911-b0a4-20116217ed84
md"""
Then, average productivity is such as:

``AP_A = \frac{y_A}{r_1x_{1,A}+r_2x_{2,A}}``
"""

# ╔═╡ ee1edd0d-4765-490a-8359-2e1a0c653096
md"""
However, market prices for inputs and / or outputs are not always available. 
In that case, we need to construct **shadow prices** for aggregation of inputs or outputs.
"""

# ╔═╡ 0932cf00-a410-4754-8ec2-d4be02e81e11
md"""
#### Parametric vs. Nonparametric Methods

To measure the technical efficiency of an observed input-output combination, we need to know the maximum quantity of output thant can be produced from the relevant input bundle. 

One possibility would be to explicitly specify a production function, givin the maximum producible output quantity at an input level.

The more common approach is to estimate the parameters of this specified production function from a sample of input-output data. 

In that case, **least squares approach fails to construct a production frontier** as it permits observed points to lie above the fitted line!

At the same time, in **deterministic and stochastic frontier models** estimated with econometric procedure, one must select:
+ A particular functional form (Cobb-Douglas for example)
+ Specify the probability distributions for the disturbance terms

Therefore, **results in this models are particularly sensible to the choices made on these two parameters**.

"""

# ╔═╡ 13d38903-5d0b-4c5d-84f0-500592feab51
md"""
**Data Envelopment Analysis (DEA) is an alternative nonparametric method for measuring efficiency, using mathematical programming rather than regression**, with:
+ No specification of an explicit form of the production function
+ Only a minimum number of assumptions about the underlying technology

In DEA, a **benchmark technology** is constructed from the observed input-output combinations of the firms in the sample. To do so, general assumptions about the production technology are made, without specifying any functional form:
"""

# ╔═╡ e05db7bd-5124-430d-92e3-5d9823560e3c
md"""
+ Assumption 1: All actually observed input-output combinations are feasible. An input-output bundle ``(x,y)`` is feasible when the output bundle ``y`` can be produced from the input bundle ``x``.
"""

# ╔═╡ 969748ac-bacf-4c6d-89ea-d7fc8d35b93c
md"""
+ Assumption 2: The production possibility set is convex. This means that if ``(x^A, y^A)`` and ``(x^B,y^B)`` are feasible, then the weighted average input-output ``(\bar{x}, \bar{y})`` with ``\bar{x} = \lambda x^A + (1 - \lambda) x^B`` and ``\bar{y} = \lambda y^A + (1-\lambda) y^B`` for ``0 \leq \lambda \leq 1`` is also feasible.
"""

# ╔═╡ c4ba41bc-a03b-4cc4-a1f3-82e5a12d0602
md"""
+ Assumption 3: Inputs are freely disposable. This means that if ``(x^0,y^0)`` is feasible, then for ``x \geq x^0``, ``(x, y^0)`` is also feasible.
"""

# ╔═╡ 7ca48a2d-eaa6-45ea-93b2-668b41223fa3
md"""
+ Assumption 4: Outputs are freely disposable. If ``(x^0, y^0)`` is feasibile then for ``y \leq y^0``, ``(x^0, y)`` is also feasible.
"""

# ╔═╡ 4548237d-1abf-48ce-9f9c-323d20dd4fe8
md"""
Based on these assumptions (and some more regarding the returns to scale status, will see it later), **it is possible to construct a production possibility set from the observed data by linear programming, without any explicit specification of a production function!**
"""

# ╔═╡ f994ab44-d916-4b04-a3fd-629235c7d5e6


# ╔═╡ 980d4941-f2f2-428f-9cfc-34c0e4b40bb3


# ╔═╡ 4fa1d732-2326-45b9-887d-85489b212751


# ╔═╡ d0248991-2c20-4f09-af45-260f9867f965


# ╔═╡ e6efd9c5-767a-4936-8859-9c7d5938ccd3


# ╔═╡ bb85f837-5836-4bfd-a9a8-01af355640cf


# ╔═╡ 577d253f-3725-4375-bbc4-cce9d4f90540


# ╔═╡ 1729192e-0746-456c-b10e-9b1128d965db


# ╔═╡ 705c6f3c-8bfa-44b8-ab40-6ba87ce91fc2


# ╔═╡ d10557b6-330d-4e4c-b141-bf294f1de8d2


# ╔═╡ 25bb36d8-5318-45dd-ac2b-9240095f225f


# ╔═╡ bfa51aeb-e2ec-4bb1-b198-d55bdc86ca40


# ╔═╡ 20c16857-04b2-490a-83cb-8d02a7399523


# ╔═╡ 6cebde0c-bfda-44cd-ba1f-1c26726103ef


# ╔═╡ e03051f6-f4e6-436e-a0b0-dc81b424bdd4


# ╔═╡ 41f98e8e-ec47-4093-84e8-e7522e8aa49f


# ╔═╡ 7416bc93-d0a7-40c8-b74a-8d297ad62582


# ╔═╡ ad45040d-7483-497f-9414-8c518adb6d37


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
COSMO = "1e616198-aa4e-51ec-90a2-23f7fbd31d8d"
DataEnvelopmentAnalysis = "a100299e-89d6-11e9-0fa0-2daf497e6a05"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
NamedArrays = "86f7a689-2022-50b4-a561-43c23ac3c673"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
COSMO = "~0.8.1"
DataEnvelopmentAnalysis = "~0.6.0"
Distributions = "~0.25.18"
JuMP = "~0.21.10"
LaTeXStrings = "~1.2.1"
NamedArrays = "~0.9.6"
Plots = "~1.22.4"
PlutoUI = "~0.7.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AMD]]
deps = ["Libdl", "LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "fc66ffc5cff568936649445f58a55b81eaf9592c"
uuid = "14f7f29c-3bd6-536c-9a0b-7339e30b5a3e"
version = "0.4.0"

[[ASL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "370cafc70604b2522f2c7cf9915ebcd17b4cd38b"
uuid = "ae81ac8f-d209-56e5-92de-9978fef736f9"
version = "0.1.2+0"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[COSMO]]
deps = ["AMD", "COSMOAccelerators", "DataStructures", "IterTools", "LinearAlgebra", "MathOptInterface", "Pkg", "Printf", "QDLDL", "Random", "Reexport", "Requires", "SparseArrays", "Statistics", "SuiteSparse", "Test", "UnsafeArrays"]
git-tree-sha1 = "364b4495ef937ce5bad347bf04e9369f292aaae0"
uuid = "1e616198-aa4e-51ec-90a2-23f7fbd31d8d"
version = "0.8.1"

[[COSMOAccelerators]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "b1153b40dd95f856e379f25ae335755ecc24298e"
uuid = "bbd8fffe-5ad0-4d78-a55e-85575421b4ac"
version = "0.1.0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "a325370b9dd0e6bf5656a6f1a7ae80755f8ccc46"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.7.2"

[[CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataEnvelopmentAnalysis]]
deps = ["GLPK", "InvertedIndices", "Ipopt", "JuMP", "LinearAlgebra", "Printf", "ProgressMeter", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "1963d200ee80d2f148c07099dbe1be8bded3726a"
uuid = "a100299e-89d6-11e9-0fa0-2daf497e6a05"
version = "0.6.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "7220bc21c33e990c14f4a9a319b1d242ebc5b269"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.3.1"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "ff7890c74e2eaffbc0b3741811e3816e64b6343d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.18"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "29890dfbc427afa59598b8cfcc10034719bd7744"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.6"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "c4203b60d37059462af370c4f3108fb5d155ff13"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.20"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GLPK]]
deps = ["BinaryProvider", "CEnum", "GLPK_jll", "Libdl", "MathOptInterface"]
git-tree-sha1 = "833dbc8fbb0554e31186df509d67fc2f78f1bb09"
uuid = "60bf3e95-4087-53dc-ae20-288a0d20c6a6"
version = "0.14.14"

[[GLPK_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01de09b070d4b8e3e1250c6542e16ed5cad45321"
uuid = "e8aa6df9-e6ca-548a-97ff-1f85fc5b8b98"
version = "5.0.0+0"

[[GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ef49a187604f865f4708c90e3f431890724e9012"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.59.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[Ipopt]]
deps = ["BinaryProvider", "Ipopt_jll", "Libdl", "LinearAlgebra", "MathOptInterface", "MathProgBase"]
git-tree-sha1 = "380786b4929b8d18d76e909c6b2eca355b7c3bd6"
uuid = "b6b21f68-93f8-5de0-b562-5493be1d77c9"
version = "0.7.0"

[[Ipopt_jll]]
deps = ["ASL_jll", "Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "MUMPS_seq_jll", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "82124f27743f2802c23fcb05febc517d0b15d86e"
uuid = "9cc047cb-c261-5740-88fc-0cf96f7bdcc7"
version = "3.13.4+2"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "2f49f7f86762a0fbbeef84912265a1ae61c4ef80"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "0.3.4"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[JuMP]]
deps = ["Calculus", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MathOptInterface", "MutableArithmetics", "NaNMath", "Printf", "Random", "SparseArrays", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "4358b7cbf2db36596bdbbe3becc6b9d87e4eb8f5"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "0.21.10"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[METIS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2dc1a9fc87e57e32b1fc186db78811157b30c118"
uuid = "d00139f3-1899-568f-a2f0-47f597d42d70"
version = "5.1.0+5"

[[MUMPS_seq_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "METIS_jll", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "1a11a84b2af5feb5a62a820574804056cdc59c39"
uuid = "d7ed1dd3-d0ae-5e8e-bfb4-87a502085b8d"
version = "5.2.1+4"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "JSON", "JSONSchema", "LinearAlgebra", "MutableArithmetics", "OrderedCollections", "SparseArrays", "Test", "Unicode"]
git-tree-sha1 = "575644e3c05b258250bb599e57cf73bbf1062901"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "0.9.22"

[[MathProgBase]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9abbe463a1e9fc507f12a69e7f29346c2cdc472c"
uuid = "fdba3010-5040-5b88-9595-932c9decdf73"
version = "0.7.8"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "3927848ccebcc165952dc0d9ac9aa274a87bfe01"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.2.20"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ba4a8f683303c9082e84afba96f25af3c7fb2436"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.12+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "6841db754bd01a91d281370d9a0f8787e220ae08"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.4"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "d1fb76655a95bf6ea4348d7197b22e889a4375f4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.14"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[QDLDL]]
deps = ["AMD", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "417caffa5e8d8de61af9a6bb0ae2a5dcbbdccac3"
uuid = "bfc457fd-c171-5ab7-bd9e-d5dbfc242d63"
version = "0.1.4"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "793793f1df98e3d7d554b65a107e9c9a6399a6ed"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.7.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnsafeArrays]]
git-tree-sha1 = "038cd6ae292c857e6f91be52b81236607627aacd"
uuid = "c4a57d5a-5b31-53a6-b365-19f8c011fbd6"
version = "1.0.3"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═ae0f4b49-de27-4ec1-8d3e-de41a6b95abb
# ╠═1bb58003-a908-4658-bce9-67b892cec480
# ╟─734f53b8-35df-4da3-a4e3-dc4718239ba0
# ╟─9a2e6ed7-a398-4717-9a95-732b0337405e
# ╟─6bf52b00-1881-11ec-2ec9-85c3a45c0752
# ╟─4d6245c1-566d-4f90-9083-0a61d119dbed
# ╟─7b32a506-aae5-4af5-ad1f-3a16301d7a2c
# ╟─3e0dc5d4-ee2b-462a-8f39-ba15c164b5a7
# ╟─210a0931-91e4-4a4e-8ed4-1be890455b3f
# ╟─b84cfdb6-855b-4c13-871c-a495a68495a3
# ╟─13df1f5c-07a7-4528-8dcc-cf650faa520c
# ╟─d36b49c9-f9b7-4e60-a084-ce7569544fd0
# ╟─66ed22ac-a715-4ecb-98be-66403e62b486
# ╟─7ac93c3e-7385-49e3-8a03-bbfebeb862b0
# ╟─4e7045a5-5b82-4af1-9199-f06c99e2692d
# ╟─533fd3d5-dce3-4d87-b251-09ed696fb9d1
# ╟─5c88a644-473f-4f81-87bd-b2a5856a539c
# ╟─70b18cb1-56f0-4d08-b29e-ff8259fd7886
# ╟─8642a6f6-0185-4f07-8689-725356c7b2c7
# ╟─5319b650-e0a4-40ec-b0de-39a542142e16
# ╟─4c33d74d-4a48-4be7-b1f0-8fd9edcf19a8
# ╟─c86b8a58-5f84-42cf-b4ea-2d0a638588aa
# ╠═d59e0941-5b9f-40a4-8b52-f05e0df7494b
# ╠═2561df55-6aea-430f-9466-4c4a52a54990
# ╟─8ef5645f-c477-473c-9de9-d0c4c4bca856
# ╟─231d83b3-6706-4823-9cff-f0895a1dabc7
# ╟─b29369e6-d184-4741-ad57-739af4c9677f
# ╟─84b1e005-ea4f-46f6-a2f1-4919897268a4
# ╟─8515eb6f-cac7-4eca-a02e-fb1f07607324
# ╟─21040d14-f76c-48bb-8f17-da152450e609
# ╟─d057a510-f3ea-45f2-9194-87d4c671e988
# ╟─49a30cab-45fe-4ff7-b78f-0badee3c2122
# ╟─2aacf9af-b3f5-4637-bd57-ad2723c3d0d0
# ╟─280cff5e-5be0-4362-972d-e6c033cdeafd
# ╟─debae212-c156-47bd-b78a-01244febe926
# ╟─14beb5b4-e92a-4c70-adf8-9a30c3d0dd70
# ╟─4b3eaa5e-9fda-4e24-81ee-aaaad80aaa24
# ╠═d19488e9-4cf5-4c9f-b70b-c57ba868a60f
# ╠═80bf800d-dbd0-4786-ab04-1900acfde278
# ╟─46c3247f-5fd2-427e-a77d-34a992497825
# ╟─a6c9df5b-638f-4f5d-8dc8-5b77987d77a1
# ╠═79103498-20f7-44b3-98f9-8392edbae08e
# ╟─e7094a2c-2a82-4304-ac77-1d406eabd72f
# ╠═bc0c5077-2db9-4046-aefb-28436b061400
# ╟─23d4d2af-152a-4b61-93b7-e7592fb63c11
# ╠═3bab3f20-50c5-4beb-a35d-444da1db238e
# ╟─09edf76b-a194-4cd2-8851-7a730a70b16d
# ╠═43c4dd4a-479c-42e0-987b-804eb0a19d1d
# ╟─bf5e03fd-2bb4-4c47-a03f-0e6beab6b29e
# ╟─8dc80971-b6a5-40da-8e7e-f496747f464a
# ╟─6a2849f9-c079-461f-a7d4-4fc9ecdbe271
# ╟─d4580ae3-5e82-4afa-8c66-e19099706ec7
# ╟─bf84d0b3-20c5-4678-8cb9-4c409a336896
# ╟─cf18e352-5493-4f2b-8f68-93b1c2d38ac1
# ╟─934f70b5-5871-4911-b0a4-20116217ed84
# ╟─ee1edd0d-4765-490a-8359-2e1a0c653096
# ╟─0932cf00-a410-4754-8ec2-d4be02e81e11
# ╠═13d38903-5d0b-4c5d-84f0-500592feab51
# ╟─e05db7bd-5124-430d-92e3-5d9823560e3c
# ╟─969748ac-bacf-4c6d-89ea-d7fc8d35b93c
# ╟─c4ba41bc-a03b-4cc4-a1f3-82e5a12d0602
# ╟─7ca48a2d-eaa6-45ea-93b2-668b41223fa3
# ╟─4548237d-1abf-48ce-9f9c-323d20dd4fe8
# ╠═f994ab44-d916-4b04-a3fd-629235c7d5e6
# ╠═980d4941-f2f2-428f-9cfc-34c0e4b40bb3
# ╠═4fa1d732-2326-45b9-887d-85489b212751
# ╠═d0248991-2c20-4f09-af45-260f9867f965
# ╠═e6efd9c5-767a-4936-8859-9c7d5938ccd3
# ╠═bb85f837-5836-4bfd-a9a8-01af355640cf
# ╠═577d253f-3725-4375-bbc4-cce9d4f90540
# ╠═1729192e-0746-456c-b10e-9b1128d965db
# ╠═705c6f3c-8bfa-44b8-ab40-6ba87ce91fc2
# ╠═d10557b6-330d-4e4c-b141-bf294f1de8d2
# ╠═25bb36d8-5318-45dd-ac2b-9240095f225f
# ╠═bfa51aeb-e2ec-4bb1-b198-d55bdc86ca40
# ╠═20c16857-04b2-490a-83cb-8d02a7399523
# ╠═6cebde0c-bfda-44cd-ba1f-1c26726103ef
# ╠═e03051f6-f4e6-436e-a0b0-dc81b424bdd4
# ╠═41f98e8e-ec47-4093-84e8-e7522e8aa49f
# ╠═7416bc93-d0a7-40c8-b74a-8d297ad62582
# ╠═ad45040d-7483-497f-9414-8c518adb6d37
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
