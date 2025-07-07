module ALU_Control (
    input wire is_immediate_i,
    input wire [1:0] ALU_CO_i,
    input wire [6:0] FUNC7_i,
    input wire [2:0] FUNC3_i,
    output reg [3:0] ALU_OP_o
);

	// Definições dos opcodes da ALU, conforme Lab28/Lab29 para ALU_OP_o.
    // Estes são os valores que o ALU_Control deve gerar para a ALU.
    localparam ALU_AND             = 4'b0000;
    localparam ALU_OR              = 4'b0001;
    localparam ALU_XOR             = 4'b1000;
    localparam ALU_NOR             = 4'b1001; // Não mapeado diretamente a partir dos campos RISC-V padrão
    localparam ALU_SUM             = 4'b0010;
    localparam ALU_SUB             = 4'b1010;
    localparam ALU_EQUAL           = 4'b0011;
    localparam ALU_GREATER_EQUAL   = 4'b1100;
    localparam ALU_GREATER_EQUAL_U = 4'b1101;
    localparam ALU_SLT             = 4'b1110;
    localparam ALU_SLT_U           = 4'b1111;
    localparam ALU_SHIFT_LEFT      = 4'b0100;
    localparam ALU_SHIFT_RIGHT     = 4'b0101;
    localparam ALU_SHIFT_RIGHT_A   = 4'b0111;

    // Bloco always para a lógica combinacional.
    // O '*' na lista de sensibilidade (@*) garante que o bloco reaja a qualquer mudança nas entradas,
    // o que é essencial para circuitos combinacionais.
    always @(*) begin
        // Valor padrão para a saída para evitar latches.
        // Usamos X (desconhecido) para indicar um opcode não mapeado/inválido.
        ALU_OP_o = 4'bXXXX;

        case (ALU_CO_i)
            // Grupo LOAD/STORE: ALU sempre faz uma soma para calcular o endereço
            2'b00: begin // LOAD/STORE [Lab29 - Controle da ALU.pdf]
                ALU_OP_o = ALU_SUM;
            end

            // Grupo BRANCH: ALU faz algum tipo de comparação, definida pelo funct3
            2'b01: begin // BRANCH [Lab29 - Controle da ALU.pdf]
                case (FUNC3_i)
                    3'b000: ALU_OP_o = ALU_EQUAL;           // BEQ (Equal)
                    3'b001: ALU_OP_o = ALU_EQUAL;           // BNE (Not Equal, baseado em igualdade)
                    3'b100: ALU_OP_o = ALU_SLT;             // BLT (Set Less Than, com sinal)
                    3'b101: ALU_OP_o = ALU_GREATER_EQUAL;   // BGE (Greater Equal, com sinal)
                    3'b110: ALU_OP_o = ALU_SLT_U;           // BLTU (Set Less Than, sem sinal)
                    3'b111: ALU_OP_o = ALU_GREATER_EQUAL_U; // BGEU (Greater Equal, sem sinal)
                    default: ALU_OP_o = 4'bXXXX; // Combinação funct3 inválida para BRANCH
                endcase
            end

            // Grupo ALU: Operações variadas, dependem de funct3, funct7 e is_immediate_i
            2'b10: begin // ALU [Lab29 - Controle da ALU.pdf]
                case (FUNC3_i)
                    3'b000: begin // Grupo ADD/ADDI/SUB [Lab29 - Controle da ALU.pdf]
                        if (is_immediate_i == 1'b0) begin // ADDI [Lab29 - Controle da ALU.pdf]
                            ALU_OP_o = ALU_SUM;
                        end else begin // ADD/SUB (R-type) [Lab29 - Controle da ALU.pdf]
                            if (FUNC7_i == 7'b0000000) begin // ADD [Lab29 - Controle da ALU.pdf]
                                ALU_OP_o = ALU_SUM;
                            end else if (FUNC7_i == 7'b0100000) begin // SUB [Lab29 - Controle da ALU.pdf]
                                ALU_OP_o = ALU_SUB;
                            end else begin
                                ALU_OP_o = 4'bXXXX; // Combinação funct3/funct7 inválida
                            end
                        end
                    end
                    3'b001: ALU_OP_o = ALU_SHIFT_LEFT;  // SLL/SLLI
                    3'b010: ALU_OP_o = ALU_SLT;         // SLT/SLTI
                    3'b011: ALU_OP_o = ALU_SLT_U;       // SLTU/SLTUI
                    3'b100: ALU_OP_o = ALU_XOR;         // XOR/XORI
                    3'b101: begin // Grupo SRL/SRLI/SRA/SRAI
                        if (FUNC7_i == 7'b0000000) begin // SRL/SRLI
                            ALU_OP_o = ALU_SHIFT_RIGHT;
                        end else if (FUNC7_i == 7'b0100000) begin // SRA/SRAI
                            ALU_OP_o = ALU_SHIFT_RIGHT_A;
                        end else begin
                            ALU_OP_o = 4'bXXXX; // Combinação funct3/funct7 inválida
                        end
                    end
                    3'b110: ALU_OP_o = ALU_OR;          // OR/ORI
                    3'b111: ALU_OP_o = ALU_AND;         // AND/ANDI
                    default: ALU_OP_o = 4'bXXXX; // Combinação funct3 inválida para ALU
                endcase
            end

            // Grupo Inválido: Saída desconhecida
            2'b11: begin // Inválido [Lab29 - Controle da ALU.pdf]
                ALU_OP_o = 4'bXXXX;
            end
            default: ALU_OP_o = 4'bXXXX; // Caso improvável de ALU_CO_i ser X ou Z
        endcase
    end


endmodule
