# Contributing to HF Oracle Batch

¡Gracias por tu interés en contribuir al proyecto HF Oracle Batch! Este documento proporciona las pautas para contribuir al proyecto.

## 📋 Cómo Contribuir

### 🐛 Reportar Bugs

1. **Busca en los issues existentes** para evitar duplicados
2. **Crea un nuevo issue** con la siguiente información:
   - Descripción clara del problema
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Versión de Oracle Database
   - Información del sistema

### 💡 Sugerir Mejoras

1. **Crea un issue** con la etiqueta `enhancement`
2. **Describe la funcionalidad** que te gustaría ver
3. **Explica el caso de uso** y beneficios

### 🔧 Contribuir Código

#### Prerrequisitos

- Oracle Database 12c o superior
- Conocimiento de PL/SQL
- Entorno de desarrollo configurado

#### Proceso de Contribución

1. **Fork del repositorio**
2. **Crea una rama** para tu feature/fix:
   ```bash
   git checkout -b feature/nombre-de-la-feature
   ```
3. **Desarrolla tu cambio** siguiendo las pautas de código
4. **Prueba tu código** exhaustivamente
5. **Commit con mensaje descriptivo**:
   ```bash
   git commit -m "feat: add new batch monitoring function"
   ```
6. **Push a tu fork**
7. **Crea un Pull Request**

## 📝 Estándares de Código

### PL/SQL Conventions

#### Naming Conventions

```sql
-- Packages: PCK_<MODULE>_<FUNCTIONALITY>
PCK_BATCH_MANAGER
PCK_BATCH_MGR_CHAINS

-- Tables: BATCH_<ENTITY>
BATCH_COMPANIES
BATCH_CHAINS

-- Views: V_BATCH_<PURPOSE>
V_BATCH_RUNNING_CHAINS
V_BATCH_CHAIN_EXECUTIONS

-- Functions: <action>_<entity>
CREATE_CHAIN
GET_CHAIN_BY_ID

-- Variables: <scope>_<purpose>
v_chain_id
p_company_id
```

#### Code Structure

```sql
/**
 * Package: PCK_BATCH_MANAGER
 * Description: Main batch management package
 * 
 * Author: [Your Name]
 * Date: [YYYY-MM-DD]
 * 
 * Purpose:
 *   - Manage batch chain execution
 *   - Handle process orchestration
 * 
 * Usage:
 *   - Called by batch execution engine
 *   - Used for chain lifecycle management
 */

CREATE OR REPLACE PACKAGE PCK_BATCH_MANAGER AS
    -- Type definitions
    TYPE chain_execution_type IS RECORD (
        id NUMBER,
        chain_name VARCHAR2(100),
        start_time TIMESTAMP
    );
    
    -- Function specifications
    FUNCTION create_chain(
        p_chain_name IN VARCHAR2,
        p_description IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;
    
    -- Procedure specifications
    PROCEDURE start_chain_execution(
        p_chain_name IN VARCHAR2,
        p_company_id IN NUMBER
    );
    
END PCK_BATCH_MANAGER;
/
```

#### Documentation Standards

- **Header comments** en todos los archivos
- **Column comments** en todas las tablas
- **Function/procedure documentation** con parámetros
- **Usage examples** en comentarios

### SQL Script Standards

#### Table Creation

```sql
-- Use numbered deployment scripts
@01_table.sql      -- Table definition
@02_constraints.sql -- Constraints
@03_triggers.sql   -- Triggers
@04_indexes.sql    -- Indexes
@00_deploy.sql     -- Master deployment script
```

#### Error Handling

```sql
-- Always include exception handling
BEGIN
    -- Your code here
    NULL;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        pck_batch_mgr_log.log_error(
            p_message => SQLERRM,
            p_source => 'PCK_BATCH_MANAGER.create_chain'
        );
        RAISE;
END;
/
```

## 🧪 Testing

### Pruebas Requeridas

1. **Unit Tests**: Para cada función/procedimiento
2. **Integration Tests**: Para flujos completos
3. **Performance Tests**: Para operaciones críticas

### Ejemplo de Test

```sql
-- Test script example
DECLARE
    v_result NUMBER;
    v_expected NUMBER := 1;
BEGIN
    -- Test setup
    DELETE FROM BATCH_CHAINS WHERE code = 'TEST_CHAIN';
    
    -- Execute test
    v_result := pck_batch_manager.create_chain('TEST_CHAIN', 'Test chain');
    
    -- Assert
    IF v_result = v_expected THEN
        DBMS_OUTPUT.PUT_LINE('Test PASSED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Test FAILED: Expected ' || v_expected || ', got ' || v_result);
    END IF;
    
    -- Cleanup
    DELETE FROM BATCH_CHAINS WHERE code = 'TEST_CHAIN';
END;
/
```

## 📋 Pull Request Guidelines

### Checklist

- [ ] Código sigue las convenciones de nomenclatura
- [ ] Documentación actualizada
- [ ] Pruebas incluidas
- [ ] No hay errores de compilación
- [ ] Funciona en Oracle 12c+
- [ ] Mensaje de commit descriptivo

### Template de Pull Request

```markdown
## Descripción
Breve descripción de los cambios

## Tipo de Cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Mejora de documentación
- [ ] Refactoring

## Pruebas Realizadas
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

## Impacto
Descripción del impacto en el sistema

## Checklist
- [ ] Mi código sigue las pautas del proyecto
- [ ] He actualizado la documentación
- [ ] He agregado pruebas para mis cambios
```

## 🏷️ Commit Message Format

Usa el formato convencional de commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formato de código
- `refactor`: Refactoring
- `test`: Pruebas
- `chore`: Tareas de mantenimiento

### Examples
```
feat(manager): add chain execution timeout
fix(monitor): resolve memory leak in log viewer
docs(readme): update installation instructions
```

## 🤝 Comunidad

### Código de Conducta

- Sé respetuoso y inclusivo
- Mantén un ambiente profesional
- Ayuda a otros contribuidores
- Reporta comportamiento inapropiado

### Canales de Comunicación

- **Issues**: Para bugs y mejoras
- **Discussions**: Para preguntas generales
- **Email**: edogt@hotmail.com

## 📚 Recursos Adicionales

- [README.md](README.md) - Documentación principal
- [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) - Arquitectura del sistema
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Guía de deployment

---

¡Gracias por contribuir al HF Oracle Batch! 🚀 