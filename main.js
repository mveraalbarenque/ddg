document.addEventListener("DOMContentLoaded", function () {
  const fnAux = ({ target }) => {
    const file = target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => readerOnLoad(e);
      reader.readAsText(file);
    }
  };
  document.getElementById("fileInput").addEventListener("change", (e) => fnAux(e));
});

const readerOnLoad = ({ target }) => {
  const sql = target.result;
  const { dbName, tables } = parseSQL(sql);
  renderTable(tables);
  renderTableLinks(dbName, tables);
};

const renderTable = (tables) => {
  const tablesContainer = document.getElementById("tables-container");
  tablesContainer.innerHTML = "";
  tables.forEach((table) => {
    const newElement = createTableElement(table);
    tablesContainer.appendChild(newElement);
  });
};

const renderTableLinks = (dbName, tables) => {
  const nameDb = document.getElementById("name-db");
  const tableList = document.getElementById("table-list");
  nameDb.innerHTML = "";
  tableList.innerHTML = "";

  nameDb.innerHTML = `<strong>DB Name:</strong> ${dbName}`;

  tables.forEach((table) => {
    const listItem = document.createElement("li");
    const link = document.createElement("a");

    link.href = `#public.${table.name}`; // Enlace a la tabla
    link.textContent = `public.${table.name}`; // Texto visible
    listItem.appendChild(link);

    tableList.appendChild(listItem); // Agregar el item a la lista
  });
};

const parseSQL = (sql) => {
  const dbRegex = /(?:CREATE DATABASE|SCHEMA|USE)\s+(\w+)/i;
  const tableRegex = /CREATE TABLE "?(\w+)"? \(([\s\S]*?)\);/g;

  const dbMatch = sql.match(dbRegex);
  const dbName = dbMatch ? dbMatch[1] : "unknown";

  const tables = [];
  let match;

  while ((match = tableRegex.exec(sql)) !== null) {
    const tableDefinition = match[2];
    const columns = parseColumns(tableDefinition);
    const constraints = parseConstraints(tableDefinition);

    const columnMap = new Map(columns.map((col) => [col.name, col]));

    const setProperties = (type, constraintColumns) => {
      const property = type === "PRIMARY KEY" ? "pk" : type === "FOREIGN KEY" ? "fk" : type === "UNIQUE" ? "uq" : null;

      if (property) {
        constraintColumns.forEach((obj) => {
          const column = columnMap.get(obj);
          if (column) column[property] = true;
        });
      }
    };

    constraints.forEach(({ type, columns: constraintColumns }) => setProperties(type, constraintColumns));

    const newTable = {
      name: match[1],
      columns,
      constraints,
    };
    tables.push(newTable);
  }
  return { dbName, tables };
};

const parseConstraints = (definition) => {
  const constraints = [];
  const constraintRegex = /CONSTRAINT (\w+) (PRIMARY KEY|FOREIGN KEY|UNIQUE) \(([\w, ]+)\)/g;
  let match;

  while ((match = constraintRegex.exec(definition)) !== null) {
    const newContraint = {
      name: match[1],
      type: match[2],
      columns: match[3].split(",").map((col) => col.trim()),
    };
    constraints.push(newContraint);
  }

  return constraints;
};

const parseColumns = (definition) => {
  const columns = [];
  const columnDefinitions = definition.split(",\n");

  columnDefinitions.forEach((obj) => {
    const aux = obj.trim().split(/\s+/);
    const name = aux[0].replace(/"/g, "");
    if (name !== "CONSTRAINT") {
      const column = {
        name,
        type: aux[1],
        notNull: aux.includes("NOT"),
        defaultValue: aux.includes("DEFAULT") ? aux[aux.indexOf("DEFAULT") + 1] : "",
        pk: false,
        fk: false,
        uq: false,
        description: "",
      };

      columns.push(column);
    }
  });

  return columns;
};

const createTableElement = (table) => {
  const tableElement = document.createElement("table");
  tableElement.classList.add("table");

  const caption = document.createElement("caption");
  caption.classList.add("tab-name");
  caption.innerHTML = `
    <em>public</em>.<strong>${table.name}</strong>
    <span class="type-label">Table</span>
  `;
  tableElement.appendChild(caption);

  const thead = document.createElement("thead");
  const headerRow = document.createElement("tr");
  const headers = ["Name", "Data Type", "PK", "FK", "UQ", "Not null", "Default value", "Description"];
  headers.forEach((headerText) => {
    const th = document.createElement("th");
    th.textContent = headerText;
    headerRow.appendChild(th);
  });
  thead.appendChild(headerRow);
  tableElement.appendChild(thead);

  const tbody = document.createElement("tbody");
  table.columns.forEach((column) => {
    const row = document.createElement("tr");

    const cellData = [
      { className: "data-name", text: column.name },
      { className: "data-type", text: column.type },
      { className: "bool-field", text: column.pk ? "&#10003;" : "" },
      { className: "bool-field", text: column.fk ? "&#10003;" : "" },
      { className: "bool-field", text: column.uq ? "&#10003;" : "" },
      { className: "bool-field notNull", text: column.notNull ? "&#10003;" : "" },
      { className: "value", text: column.defaultValue || "" },
      { className: "value", text: column.description || "" },
    ];

    cellData.forEach(({ className, text }) => {
      const td = document.createElement("td");
      td.className = className;
      td.innerHTML = text; // Using innerHTML for &#10003; character
      row.appendChild(td);
    });

    tbody.appendChild(row);
  });
  tableElement.appendChild(tbody);

  return tableElement;
};
