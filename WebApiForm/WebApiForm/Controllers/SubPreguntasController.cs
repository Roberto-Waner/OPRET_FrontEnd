﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApiForm.Repository;
using WebApiForm.Repository.Models;

namespace WebApiForm.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SubPreguntasController : ControllerBase
    {
        private readonly FormEncuestaDbContext _context;

        public SubPreguntasController(FormEncuestaDbContext context)
        {
            _context = context;
        }

        // GET: api/SubPreguntas
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SubPregunta>>> GetSubPreguntas()
        {
            return await _context.SubPreguntas.ToListAsync();
        }

        // GET: api/SubPreguntas/5
        [HttpGet("{id}")]
        public async Task<ActionResult<SubPregunta>> GetSubPregunta(string id)
        {
            var subPregunta = await _context.SubPreguntas.FindAsync(id);

            if (subPregunta == null)
            {
                return NotFound();
            }

            return subPregunta;
        }

        // PUT: api/SubPreguntas/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutSubPregunta(string id, SubPregunta subPregunta)
        {
            if (id != subPregunta.CodSubPregunta)
            {
                return BadRequest();
            }

            _context.Entry(subPregunta).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!SubPreguntaExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/SubPreguntas
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<SubPregunta>> PostSubPregunta(SubPregunta subPregunta)
        {
            _context.SubPreguntas.Add(subPregunta);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (SubPreguntaExists(subPregunta.CodSubPregunta))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetSubPregunta", new { id = subPregunta.CodSubPregunta }, subPregunta);
        }

        // DELETE: api/SubPreguntas/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSubPregunta(string id)
        {
            var subPregunta = await _context.SubPreguntas.FindAsync(id);
            if (subPregunta == null)
            {
                return NotFound();
            }

            _context.SubPreguntas.Remove(subPregunta);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool SubPreguntaExists(string id)
        {
            return _context.SubPreguntas.Any(e => e.CodSubPregunta == id);
        }
    }
}
