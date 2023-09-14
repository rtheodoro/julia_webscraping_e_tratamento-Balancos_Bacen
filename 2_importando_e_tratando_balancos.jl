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
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=5, decimal=',') |> DataFrame        
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, Symbol("#DATA_BASE") => :DATA, :NOME_INSTITUICAO, :CONTA, :SALDO)
    elseif i > 1993 && i < 2010
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=4, decimal=',') |> DataFrame 
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, :DATA, Symbol("NOME INSTITUICAO") => :NOME_INSTITUICAO, :CONTA, 8 => :SALDO)
    else
        csv_i = CSV.File("data_raw/$(i)12COOPERATIVAS.CSV", delim=';', header=4, decimal=',') |> DataFrame 
        println("Tratando Balanço do ano $i")
        csv_i = filter(row -> row.DOCUMENTO == 4010, csv_i)
        csv_i = select(csv_i, :CNPJ, Symbol("#DATA_BASE") => :DATA, :NOME_INSTITUICAO, :CONTA, :SALDO)
    end

    rename!(csv_i, [Symbol("CNPJ") => :cnpj, Symbol("DATA") => :ano, Symbol("NOME_INSTITUICAO") => :razao_social])
    
    csv_i = unstack(csv_i, :CONTA, :SALDO)

    println("Unificando Balanço do ano $i")
    
    csv_coop_completo_1993a2022 = vcat(csv_coop_completo_1993a2022, csv_i, cols=:union)
    empty!(csv_i)
end

# Trocando valores missing por 0
csv_coop_completo_1993a2022 = coalesce.(csv_coop_completo_1993a2022, 0)


# Salvando .csv
CSV.write("data/balanco_coop_cred_1993a2022_4010.csv", csv_coop_completo_1993a2022, writeheader=true)


