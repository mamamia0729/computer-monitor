# Contributing to Computer Monitoring Dashboard

First off, thank you for considering contributing to Computer Monitoring Dashboard! It's people like you that make this tool better for the entire IT community.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Be respectful and inclusive
- Be patient and welcoming
- Be collaborative
- Focus on what is best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots, etc.)
- **Describe the behavior you observed** and what you expected
- **Include your environment details**:
  - OS version (e.g., Windows 11, Windows Server 2019)
  - PowerShell version (`$PSVersionTable.PSVersion`)
  - Python version (`python --version`)
  - Number of computers being monitored
  - Network environment (domain-joined, workgroup, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List any similar features** in other monitoring tools

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards (see below)
3. **Test your changes** thoroughly
   - Run `.\scripts\test-system.ps1` to validate
   - Test with various computer counts (small, medium, large lists)
   - Verify PowerShell 5.1 compatibility
4. **Update documentation** if needed
5. **Write a clear commit message** describing your changes
6. **Submit a pull request**

## Development Setup

1. Clone your fork:
   ```powershell
   git clone https://github.com/YOUR-USERNAME/computer-monitor.git
   cd computer-monitor
   ```

2. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```

3. Create a test CSV with sample data:
   ```csv
   ComputerName,Location,Status,TestTime
   TEST-PC-01,Test IDF,Online,2025-11-25 12:00:00
   TEST-PC-02,Test IDF,Online,2025-11-25 12:00:00
   ```

4. Run the system:
   ```powershell
   .\start-all.ps1
   ```

## Coding Standards

### PowerShell

- **Compatible with PowerShell 5.1+** (test on both 5.1 and 7.x)
- Use **approved verbs** for function names (`Get-`, `Set-`, `New-`, etc.)
- Include **comment-based help** for all functions
- Use **proper error handling** (`try/catch`, `-ErrorAction`)
- Follow **PowerShell best practices**:
  - Use `[Parameter()]` attributes
  - Include examples in help
  - Use meaningful variable names
  - Avoid aliases in scripts

Example:
```powershell
function Get-ComputerStatus {
    <#
    .SYNOPSIS
        Brief description
    .DESCRIPTION
        Detailed description
    .PARAMETER ComputerName
        Description of parameter
    .EXAMPLE
        Get-ComputerStatus -ComputerName "PC-01"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )
    
    # Implementation
}
```

### Python

- **Follow PEP 8** style guidelines
- Use **type hints** where appropriate
- Include **docstrings** for functions and classes
- Keep functions **small and focused**
- Use **meaningful variable names**

Example:
```python
def get_computer_status(computer_name: str) -> dict:
    """
    Get the current status of a computer.
    
    Args:
        computer_name: Name of the computer to check
        
    Returns:
        Dictionary containing status information
    """
    # Implementation
    pass
```

### JavaScript

- Use **ES6+ features** where appropriate
- Use **const/let** instead of `var`
- Include **JSDoc comments** for functions
- Follow **consistent naming conventions**

### Documentation

- Use **clear and concise language**
- Include **code examples** where helpful
- Update **README.md** for major features
- Add entries to **CHANGELOG.md** (if we create one)

## Testing

### Manual Testing Checklist

Before submitting a PR, test:
- [ ] PowerShell 5.1 compatibility
- [ ] PowerShell 7.x compatibility
- [ ] Dashboard loads correctly
- [ ] Monitoring script runs without errors
- [ ] CSV import/export works
- [ ] Remote actions (RDP restart) work
- [ ] Filters and search work correctly
- [ ] Auto-refresh functions properly
- [ ] Different screen sizes (responsive design)

### Test Scenarios

- **Small list**: 5-10 computers
- **Medium list**: 50-100 computers
- **Large list**: 200+ computers
- **Mixed status**: Some online, some offline
- **All offline**: Check error handling
- **Network issues**: Simulate unreachable computers

## Project Structure Guidelines

When adding new features:

- **Scripts**: Helper scripts go in `scripts/`
- **Documentation**: New docs go in `docs/`
- **Templates**: HTML templates go in `templates/`
- **Core logic**: Main monitoring in `monitor.ps1`, web server in `app.py`

## Feature Ideas

Looking for something to contribute? Here are some ideas:

### High Priority
- [ ] Authentication system for dashboard
- [ ] Bulk operations (restart multiple computers)
- [ ] Email notifications for state changes
- [ ] Export to CSV/Excel from dashboard

### Medium Priority
- [ ] More remote actions (restart computer, restart print spooler)
- [ ] Service status indicators (not just RDP)
- [ ] Customizable dashboard themes
- [ ] History graphs/charts

### Low Priority
- [ ] Mobile app integration
- [ ] Slack/Teams notifications
- [ ] Multiple location support (separate CSVs per site)
- [ ] Performance metrics collection

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community discussions
- Ask questions in pull requests

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
