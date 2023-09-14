# Chamando pacotes (precisa instalar antes)
using HTTP
using Printf
using Dates
using ZipFile
using Glob


primeiroano = 1993
anomaisrecente = year(now()) - 1

# Local para salvar os arquivos
datacoleta = Dates.format(now(), "yyyymm")

for i in primeiroano:anomaisrecente
    dest_file = "data_raw/$(i)12_coopcred.zip"
    
    println("Baixando balanço de Dezembro de ", i)
    
    u_bc_zip = "https://www4.bcb.gov.br/fis/cosif/cont/balan/cooperativas/$(i)12COOPERATIVAS.ZIP"
    
    response = HTTP.get(u_bc_zip)

    # Baixando os arquivos
    open(dest_file, "w") do file
        write(file, response.body)
    end
end

# Extraindo os ZIP para CSV
files = [joinpath("data_raw", file) for file in readdir("data_raw") if endswith(file, ".zip")]

outDir = "data_raw/"
for i in files
    run(`unzip $i -d $outDir`)
end

# Limpando variáveis não utilizadas
eval(Meta.parse("global " * string(var) * " = nothing") for var in [:anomaisrecente, :dest_file, :files, :i, :outDir, :primeiroano, :u_bc_zip])

