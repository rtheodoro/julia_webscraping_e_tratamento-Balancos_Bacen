using DataFrames
using Dates
using CSV
using Printf
using DelimitedFiles

primeiroano = 1993
anomaisrecente = year(now()) - 1

csv_coop_completo_1993a2022 = DataFrame()

for i in primeiroano:anomaisrecente
    println("Carregando Balanço do ano $i")
    if i == 1993
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=5) |> DataFrame        
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, Symbol("#DATA_BASE"), :NOME_INSTITUICAO, :CONTA, :SALDO)
    elseif i > 1993 && i < 2010
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=4) |> DataFrame 
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, :DATA, Symbol("NOME INSTITUICAO"), :CONTA, Symbol("SALDO"))
    else
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=4) |> DataFrame 
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, Symbol("#DATA_BASE"), :NOME_INSTITUICAO, :CONTA, :SALDO)
    end

    rename!(csv_i, [Symbol("CNPJ") => :cnpj, Symbol("#DATA_BASE") => :ano, Symbol("NOME_INSTITUICAO") => :razao_social])
    
    csv_i = unstack(csv_i, :CONTA, :SALDO)

    println("Unificando Balanço do ano $i")
    csv_coop_completo_1993a2022 = vcat(csv_coop_completo_1993a2022, csv_i)
    empty!(csv_i)
end

# Substitua 'csv_coop_completo_1993a2022' pelo nome real do seu data frame
for col in names(csv_coop_completo_1993a2022)[4:end]
    csv_coop_completo_1993a2022[!, col] = replace.(csv_coop_completo_1993a2022[!, col], r"," => ".")
    csv_coop_completo_1993a2022[!, col] = parse.(Float64, csv_coop_completo_1993a2022[!, col])
end

CSV.write("data/balanco_coop_cred_1993a2022_4010.csv", csv_coop_completo_1993a2022, writeheader=true)


