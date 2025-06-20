'use client';

import { usePathname, useRouter, useSearchParams } from 'next/navigation';

interface FilterOption {
  label: string;
  value: string;
}

export function StatusFilter({ options, filterKey, allLabel }: { options: FilterOption[], filterKey: string, allLabel?: string }) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleFilterChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const value = event.target.value;
    const params = new URLSearchParams(searchParams.toString());
    params.set('page', '1');
    if (value) {
      params.set(filterKey, value);
    } else {
      params.delete(filterKey);
    }
    replace(`${pathname}?${params.toString()}`);
  };

  const placeholder = allLabel ?? (filterKey === 'status' ? 'All Statuses' : 'All');

  return (
    <select
      className="input-field peer block w-full rounded-md border py-[9px] pl-3 pr-10 text-sm outline-2"
      onChange={handleFilterChange}
      defaultValue={searchParams.get(filterKey)?.toString() || ''}
    >
      <option value="">{placeholder}</option>
      {options.map(option => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
} 