﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace WebApiForm.Repository.Models;

[Index("Passwords", Name = "UQ__Registro__21178534EA607C1E", IsUnique = true)]
[Index("Cedula", Name = "UQ__Registro__415B7BE502A28CF1", IsUnique = true)]
[Index("Usuario", Name = "UQ__Registro__9AFF8FC6E637B81B", IsUnique = true)]
[Index("Email", Name = "UQ__Registro__AB6E61647DF25020", IsUnique = true)]
public partial class RegistroUsuario
{
    [Key]
    [Column("id_usuarios")]
    [StringLength(100)]
    [Unicode(false)]
    public string IdUsuarios { get; set; } = null!;

    [Column("cedula")]
    [StringLength(100)]
    [Unicode(false)]
    public string Cedula { get; set; } = null!;

    [Column("nombre_apellido")]
    [StringLength(200)]
    [Unicode(false)]
    public string NombreApellido { get; set; } = null!;

    [Column("usuario")]
    [StringLength(50)]
    [Unicode(false)]
    public string Usuario { get; set; } = null!;

    [Column("email")]
    [StringLength(100)]
    [Unicode(false)]
    public string Email { get; set; } = null!;

    [Column("passwords")]
    [StringLength(100)]
    [Unicode(false)]
    public string Passwords { get; set; } = null!;

    [Column("foto")]
    public byte[]? Foto { get; set; }

    [Column("fecha_creacion")]
    [StringLength(100)]
    [Unicode(false)]
    public string? FechaCreacion { get; set; }

    [Column("rol")]
    [StringLength(50)]
    [Unicode(false)]
    public string? Rol { get; set; }

    [Column("estado")]
    public bool Estado { get; set; }

    [InverseProperty("IdUsuariosNavigation")]
    public virtual ICollection<Formulario> Formularios { get; set; } = new List<Formulario>();

    [InverseProperty("IdUsuariosNavigation")]
    public virtual ICollection<Respuesta> Respuestas { get; set; } = new List<Respuesta>();
}
