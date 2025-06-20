"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function CreateProductPage() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    if (!name || !price) {
      setError('Name and price are required');
      setLoading(false);
      return;
    }
    try {
      const res = await fetch('/api/products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name,
          description,
          price: parseFloat(price),
        }),
      });
      if (res.ok) {
        router.push('/products');
      } else {
        const data = await res.json();
        setError(data.error || 'Failed to create product');
      }
    } catch (err) {
      setError('An error occurred');
    }
    setLoading(false);
  };

  return (
    <div>
      <main className="p-8">
        <h1 className="text-3xl font-bold mb-6">Create Product</h1>
        {error && <div className="mb-4 text-red-500">{error}</div>}
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow-md">
          <div className="mb-4">
            <label className="block mb-1 font-medium">Name</label>
            <input
              type="text"
              className="w-full border px-3 py-2 rounded"
              value={name}
              onChange={e => setName(e.target.value)}
              required
            />
          </div>
          <div className="mb-4">
            <label className="block mb-1 font-medium">Description</label>
            <textarea
              className="w-full border px-3 py-2 rounded"
              value={description}
              onChange={e => setDescription(e.target.value)}
              rows={4}
            />
          </div>
          <div className="mb-6">
            <label className="block mb-1 font-medium">Price</label>
            <input
              type="number"
              step="0.01"
              className="w-full border px-3 py-2 rounded"
              value={price}
              onChange={e => setPrice(e.target.value)}
              required
            />
          </div>
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition"
            disabled={loading}
          >
            {loading ? 'Creating...' : 'Create Product'}
          </button>
        </form>
      </main>
    </div>
  );
} 