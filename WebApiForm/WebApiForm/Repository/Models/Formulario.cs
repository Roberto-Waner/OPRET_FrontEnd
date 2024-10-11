﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace WebApiForm.Repository.Models;

[Table("Formulario")]
public partial class Formulario
{
    [Key]
    [Column("identifacador_form")]
    public int IdentifacadorForm { get; set; }

    [Column("no_encuesta")]
    [StringLength(100)]
    [Unicode(false)]
    public string NoEncuesta { get; set; } = null!;

    [Column("id_usuarios")]
    [StringLength(100)]
    [Unicode(false)]
    public string IdUsuarios { get; set; } = null!;

    [Column("cedula")]
    [StringLength(100)]
    [Unicode(false)]
    public string Cedula { get; set; } = null!;

    [Column("fecha")]
    [StringLength(100)]
    [Unicode(false)]
    public string? Fecha { get; set; }

    [Column("hora")]
    [StringLength(100)]
    [Unicode(false)]
    public string? Hora { get; set; }

    [Column("estacion")]
    [StringLength(200)]
    [Unicode(false)]
    public string? Estacion { get; set; }

    [Column("linea")]
    [StringLength(11)]
    [Unicode(false)]
    public string? Linea { get; set; }

    [ForeignKey("IdUsuarios")]
    [InverseProperty("Formularios")]
    public virtual RegistroUsuario? IdUsuariosNavigation { get; set; } = null!;
}
